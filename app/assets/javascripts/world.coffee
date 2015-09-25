#= require busyverse
#= require support/randomness
#= require support/pathfinding
#= require resource
#= require resources/wood
#= require grid
#= require city

class Busyverse.World
  name: 'Busylandia'

  initialPopulation: Busyverse.initialPopulation
  startingResources: Busyverse.startingResources

  constructor: (@width, @height, @cellSize) ->
    @age        = 480
    @city       = new Busyverse.City()
    @map        = new Busyverse.Grid(@width, @height)
    @resources  = []
    @pathfinder = new Busyverse.Support.Pathfinding(@map)
    @random     = new Busyverse.Support.Randomness()
    @geometry   = new Busyverse.Support.Geometry()

    if Busyverse.debug
      console.log "Created new world, '#{@name}'!"
      console.log "Dimensions of #{@name}: #{@width}x#{@height})"

  defaultDistribution: {20: 'darkgreen', 80: 'darkblue'},

  setup: (dist=@defaultDistribution, evolve=true, resources=true, build=true) =>
    console.log "World#setup" if Busyverse.trace
    origin = null

    until origin
      @map.setup(dist, evolve)
      origin = @randomPassableAreaOfSize [3,3]

    if resources
      for j in [1..@startingResources]
        position = @randomPassableCell()
        if position
          resource = new Busyverse.Resources.Wood(position)
          if Busyverse.trace
            console.log "distribute resource #{resource.name} at #{position}!"
          @resources.push resource
        else
          if Busyverse.debug
            console.log "WARNING -- could not distribute resource"

    if build
      farm = new Busyverse.Buildings.Farm(origin)
      @city.create farm

      for i in [1..@initialPopulation]
        @city.grow @

  tryToBuild: (building, create=false) =>
    passable  = @isAreaPassable(building.position, building.size)
    available = @city.availableForBuilding(building.position, building.size)
    if passable && available
      @city.create(building) if create
      true
    else
      false

  update: =>
    @city.update(@)
    @age = @age + 1

  dayStart: 6
  dayEnd: 20

  getMinute: -> @age % 60
  getHour:   -> Math.floor(@age / 60) % 24
  getDay:    -> Math.floor(@age / (60 * 24))
  isDay:     -> @getHour() >= @dayStart && @getHour() < @dayEnd

  percentOfDay: ->
    (@getHour() - @dayStart) / (@dayEnd - @dayStart)
      # normalize night too somehow... hmmm

  pad: (num, size) ->
    s = '000000000' + num
    s.substr s.length - size

  describeTime: ->
    hour = if @getHour()%12 == 0 then '12' else @getHour()%12
    min = @pad(@getMinute(),2)
    am_pm = if @getHour() >= 12 then 'PM' else 'AM'
    time = "#{hour}:#{min}#{am_pm}"
    date = "Day #{@getDay()}"
    "#{date} (#{time})"

  center: => [ @width / 2, @height / 2 ]

  canvasToMapCoordinates: (canvasCoords) =>
    x = canvasCoords[0] / @cellSize
    y = canvasCoords[1] / @cellSize
    [ Math.round(x), Math.round(y) ]

  mapToCanvasCoordinates: (mapCoords, offset=[0,0]) =>
    x = mapCoords[0] * @cellSize
    y = mapCoords[1] * @cellSize
    [ Math.round(x) + offset[0], Math.round(y) + offset[0] ]

  randomPassableAreasOfSize: (sz) =>
    if Busyverse.debug && Busyverse.verbose
      console.log "World#randomPassableAreasOfSize size=#{sz}"
    location = null
    cells = @map.allCells()
    areas = []
    for cell in cells
      console.log "consider location #{cell.location}" if Busyverse.trace
      passable_area = @isAreaPassable(cell.location, sz)
      console.log "passable? #{passable_area}" if Busyverse.trace
      if passable_area
        areas.push cell.location
    areas

  randomPassableAreaOfSize: (sz) =>
    @random.valueFromList @randomPassableAreasOfSize(sz)
    
  isAreaPassable: (loc, sz=[0,0]) =>
    console.log "World#isAreaPassable loc=#{loc} sz=#{sz}" if Busyverse.debug
    for x in [0..sz[0]-1]
      for y in [0..sz[1]-1]
        lx = loc[0] + x
        ly = loc[1] + y
        return false unless @map.isLocationPassable([lx,ly])

        for resource in @resources
          if lx == resource.position[0] && ly == resource.position[1]
            return false
    true

  findOpenAreaOfSizeInCity: (city, size, max_distance_from_center) =>
    areas = @findOpenAreasOfSizeInCity(city, size, max_distance_from_center)
    @random.valueFromList(areas)

  findOpenAreasOfSizeInCity: (city, size, max_distance_from_center) =>
    if Busyverse.debug
      console.log "World#findOpenAreasOfSizeInCity"
      console.log "size=#{size} dist_from_center=#{max_distance_from_center}"

    center = city.center()
    nearby_cells = @allCellsWithin(max_distance_from_center, center)
    areas = []

    console.log "considering nearby cells: " if Busyverse.debug
    for cell in nearby_cells
      console.log cell.location if Busyverse.debug
      passable = @isAreaPassable(cell.location, size)
      if passable
        available = city.availableForBuilding(cell.location, size)
        if available
          areas.push cell.location

    console.log "found #{areas.length} areas" if Busyverse.debug
    return areas

  allCellsWithin: (maxDistance, center) =>
    cellsInRadius = []
    @map.eachCell (cell) =>
      if @geometry.euclideanDistance(cell.location, center) <= maxDistance
        cellsInRadius.push(cell)
    cellsInRadius

  markExplored: (cellCoords) =>
    @city.explore(cellCoords) unless @isLocationExplored(cellCoords)

  isCellExplored: (cell) => @city.isExplored(cell.location)
  isLocationExplored: (location) => @city.isExplored(location)

  markExploredSurrounding: (cellCoords, depth) =>
    for cell in @allCellsWithin(depth, cellCoords)
      @markExplored(cell.location)
    
  anyUnexplored: =>
    unexplored = false
    @map.eachCell (cell) =>
      unexplored = true if !@isCellExplored(cell)
    unexplored

  nearbyUnexploredCell: (cellCoords, distance=15) =>
    if Busyverse.verbose
      console.log "World#nearbyUnexploredCell coords=#{cellCoords}"
    closest = null
    min_dist = 10000

    nearby_cells = @allCellsWithin(distance, cellCoords)
    nearby_cells = nearby_cells.filter (cell) =>
      !@isCellExplored(cell) && @map.isLocationPassable(cell.location)

    return null if nearby_cells.length == 0

    @random.valueFromList(nearby_cells).location
    
  getPath: (source, target) =>
    @pathfinder.shortestPath(source, target)

  getCellAtCanvasCoords: (coords) =>
    @map.getCellAt(@canvasToMapCoordinates(coords))

  randomCell: => [ @random.valueInRange(@width), @random.valueInRange(@height) ]

  randomPassableCell: =>
    console.log "World#randomPassableCell" if Busyverse.trace
    passableCells = @map.allCells().filter (cell) =>
      @map.isLocationPassable(cell.location)
    @random.valueFromList(passableCells).location

  randomLocation: ->
    location = [ Math.round(@random.valueInRange(@width)) * @cellSize,
                 Math.round(@random.valueInRange(@height)) * @cellSize ]
    location
