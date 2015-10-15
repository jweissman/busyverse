#= require busyverse
#= require support/randomness
#= require support/pathfinding
#= require resource
#= require resources/wood
#= require grid
#= require city
#= require terraformer

class Busyverse.World
  name: 'Busylandia'

  constructor: (@width, @height, @cellSize) ->
    @composeComplete = false
    @resourcesDistributed = false
    @woodsDeveloped = false
    @ready = false

    @age        = 480 # day zero, 8 am
    @city       = new Busyverse.City()
    @map        = new Busyverse.Grid(@width, @height)
    @resources  = []
    @pathfinder = new Busyverse.Support.Pathfinding(@map)
    @random     = new Busyverse.Support.Randomness()
    @geometry   = new Busyverse.Support.Geometry()

    if Busyverse.debug
      console.log "Created new world, '#{@name}'!"
      console.log "Dimensions of #{@name}: #{@width}x#{@height})"
      console.log @map

  defaultDistribution: {60: 'darkgreen', 40: 'darkblue'}

  setup: (dist=@defaultDistribution, evolve=true, resources=true) =>
    console.log "World#setup" if Busyverse.trace

    @terraformer = new Busyverse.Terraformer()
    console.log "1. Compose map..." if Busyverse.trace
    @map = @terraformer.compose(@map, dist, evolve)
    @composeComplete = true

  setupResources: (plan={1: 'iron', 99: 'wood'})=>
    console.log "2. Distribute resources..." if Busyverse.trace
    @distributeResources(plan)
    @resourcesDistributed = true

  developWoods: =>
    console.log "2a. Grow forests..." if Busyverse.trace
    for i in [0..6]
      @growForests()
    @woodsDeveloped = true
  
  setupBuildings: =>
    console.log "World#setupBuildings" if Busyverse.trace
    until origin
      origin = @randomPassableAreaOfSize [4,4]
    console.log "---> Found origin!" if Busyverse.trace

    buildingType = Busyverse.BuildingType.all[0]
    building = Busyverse.Building.generate buildingType.name, origin

    @city.create building
    Busyverse.engine.ui.centerAt(origin)

  distributeResources: (plan) =>
    console.log "World#distributeResources" if Busyverse.trace
    if Busyverse.debug
      console.log "resourceCount => #{Busyverse.startingResources}"
      console.log plan

    for j in [1..Busyverse.startingResources]
      resource_type = @random.valueFromPercentageMap(plan)
      sz = if resource_type == 'wood'
        (new Busyverse.Resources.Wood()).size
      else if resource_type == 'iron'
        (new Busyverse.Resources.Iron()).size

      position = @randomPassableAreaOfSize(sz)
      if position?
        if resource_type == 'wood'
          resource = new Busyverse.Resources.Wood(position, 40)

        else if resource_type == 'iron'
          resource = new Busyverse.Resources.Iron(position)
        console.log("created #{resource.name}") if Busyverse.debug
          
        @resources.push resource
      else
        if Busyverse.debug
          console.log "WARNING -- could not distribute resource"

  update: =>
    @city.update @
    @age += 1
    @growForests() if @age % (24 * 60) == 0

  growForests: =>
    to_delete = []
    for resource in @resources
      if resource.name == 'wood'
        resource.age = resource.age + 1
    for resource in to_delete
      @resources.splice(@resources.indexOf(resource), 1)

    to_create = []
    @map.eachCell (cell) =>
      return unless @isAreaPassable(cell.location)
      neighborCells = @map.getAllNeighbors(cell.location)
      neighbors = []
      for resource in @resources
        if resource.name == 'wood'
          for neighborCell in neighborCells
            if resource.position[0] == neighborCell.location[0] &&
               resource.position[1] == neighborCell.location[1]
              neighbors.push resource
      
      if neighbors.length >= 2 && neighbors.length <= 5
        if @random.valueInRange(50) >= 45 - neighbors.length
          #console.log "--- create new forest"
          resource = new Busyverse.Resources.Wood(cell.location)
          to_create.push(resource)

    for resource_to_create in to_create
      @resources.push resource_to_create

  dayStart: 6
  dayEnd: 20

  getMinute: -> @age % 60
  getHour:   -> Math.floor(@age / 60) % 24
  getDay:    -> Math.floor(@age / (60 * 24))
  isDay:     -> @getHour() >= @dayStart && @getHour() < @dayEnd

  percentOfDay: ->
    (@getHour() - @dayStart) / (@dayEnd - @dayStart)

  pad: (num, size) ->
    s = '000000000' + num
    s.substr s.length - size

  describeDate: -> "Day #{@getDay()}"

  describeTime: ->
    hour = if @getHour()%12 == 0 then '12' else @getHour()%12
    min = @pad(@getMinute(),2)
    am_pm = if @getHour() >= 12 then 'PM' else 'AM'
    "#{hour}:#{min}#{am_pm}"

  center: => [ @width / 2, @height / 2 ]

  canvasToMapCoordinates: (canvasCoords) =>
    x = canvasCoords[0] / @cellSize
    y = canvasCoords[1] / @cellSize
    [ Math.round(x), Math.round(y) ]

  mapToCanvasCoordinates: (mapCoords, offset=[0,0]) =>
    x = mapCoords[0] * @cellSize
    y = mapCoords[1] * @cellSize
    [ Math.round(x) + offset[0], Math.round(y) + offset[0] ]

  tryToBuild: (building, create=false) =>
    console.log "World#tryToBuild" if Busyverse.trace
    { position, size, name } = building

    passable  = @isAreaPassable position, size
    available = @city.availableForBuilding position, size, name

    if Busyverse.debug
      console.log "--- passable? #{passable} -- available? #{available}"

    if passable && available
      @city.create(building) if create
      true
    else
      false

  randomPassableAreasOfSize: (sz,n=2) =>
    if Busyverse.debug && Busyverse.verbose
      console.log "World#randomPassableAreasOfSize size=#{sz}"

    location = null
    areas = []
    @shuffledCells ?= @random.shuffle(@map.allCells())

    for cell in @shuffledCells
      console.log "consider location #{cell.location}" if Busyverse.trace
      passable_area = @isAreaPassable(cell.location, sz)
      console.log "passable? #{passable_area}" if Busyverse.trace

      if passable_area
        areas.push cell.location
        return areas if areas.length >= n
    areas

  randomPassableAreaOfSize: (sz) =>
    @random.valueFromList @randomPassableAreasOfSize(sz)
    
  isAreaPassable: (loc, sz=[1,1]) =>
    console.log "World#isAreaPassable loc=#{loc} sz=#{sz}" if Busyverse.debug
    for x in [0..sz[0]-1]
      for y in [0..sz[1]-1]
        lx = loc[0] + x
        ly = loc[1] + y
        return false unless @map.isLocationPassable([lx,ly])
        if @buildings && @buildings.length > 0
          for building in @buildings
            if building.doesOverlap([lx,ly]) #,[1,1])
              return false
        for resource in @resources
          if resource.doesOverlap([lx,ly],[1,1])
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
    @cellPatterns ?= {}
    unless @cellPatterns[maxDistance]
      @cellPatterns[maxDistance] = @computeCellPattern(maxDistance)
    pattern = @cellPatterns[maxDistance]
    @applyCellPattern pattern, center

  computeCellPattern: (dist) ->
    pattern = []
    distance = Math.ceil(dist) + 1
    for x in [-(distance)..(distance)]
      for y in [-(distance)..(distance)]
        if @geometry.euclideanDistance([x,y], [0,0]) <= dist
          pattern.push([x,y])
    pattern

  applyCellPattern: (pattern, origin) ->
    cells = []
    for xy in pattern
      x = Math.floor(xy[0] + origin[0])
      y = Math.floor(xy[1] + origin[1])
      target = [ x, y ]
      cell = @map.getCellAt target
      if cell
        cells.push cell
    cells

  markExplored: (cellCoords) =>
    @city.explore(cellCoords) unless @isLocationExplored(cellCoords)

  isCellExplored: (cell) => @city.isExplored(cell.location)
  isLocationExplored: (location) => @city.isExplored(location)

  isAnyPartOfAreaExplored: (loc, sz) =>
    for x in [0..sz[0]-1]
      for y in [0..sz[1]-1]
        lx = loc[0] + x
        ly = loc[1] + y
        return true if @isLocationExplored([lx,ly])
    false
    
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

  nearbyCell: (cellCoords, distance=15) =>
    if Busyverse.verbose
      console.log "World#nearbyUnexploredCell coords=#{cellCoords}"
    closest = null
    min_dist = 10000

    nearby_cells = @allCellsWithin(distance, cellCoords)
    nearby_cells = nearby_cells.filter (cell) =>
      @map.isLocationPassable(cell.location)

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
