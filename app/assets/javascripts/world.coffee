#= require support/randomness
#= require support/pathfinding
#= require grid
#= require city

class Busyverse.World
  name: 'Busylandia'

  constructor: (@width, @height, @cellSize) ->
    @width   ?= 200
    @height  ?= 200

    @city       = new Busyverse.City()
    @map        = new Busyverse.Grid(@width, @height)
    @pathfinder = new Busyverse.Support.Pathfinding(@map)

    @random   = new Busyverse.Support.Randomness()
    @geometry = new Busyverse.Support.Geometry()

    console.log("Created new world, '#{@name}'! (Dimensions: #{@width}x#{@height})") if Busyverse.debug

  update: =>
    @city.update(@)

  center: => 
    [ @width / 2, @height / 2 ]

  mapToCanvasCoordinates: (pos) => 
    [ @cellSize * pos[0], @cellSize * pos[1] ]

  canvasToMapCoordinates: (canvasCoords) =>
    x = canvasCoords[0] / @cellSize
    y = canvasCoords[1] / @cellSize

    [ Math.round(x), Math.round(y) ]

  mapToCanvasCoordinates: (mapCoords) =>
    x = mapCoords[0] * @cellSize
    y = mapCoords[1] * @cellSize

    [ Math.round(x), Math.round(y) ]

  randomPassableAreaOfSize: (sz) =>
    console.log "World#randomPassableAreaOfSize size=#{sz}"
    #location = null
    # passable_area = false
    # until passable_area
    #  location = @randomCell()

    location = null
    cells = @map.allCells()
    # @map.eachCell (cell) =>
    for cell in cells
      console.log "consider location #{cell.location}"
      passable_area = @isAreaPassable(cell.location, sz) 
      console.log "passable? #{passable_area}"
      if passable_area 
        return cell.location
    null

  isAreaPassable: (loc, sz) =>
    console.log "World#isAreaPassable loc=#{loc} sz=#{sz}"
    for x in [0..sz]
      for y in [0..sz]
        if !@map.isLocationPassable([x,y]) #getCellAt([x,y]).isPassable()
          return false
    true

  findOpenAreaOfSizeInCity: (city, size, max_distance_from_center, current_location) =>
    console.log "World#findOpenAreasOfSizeInCity"
    open_areas = []
    # max_distance_from_center ?= 3*city.population.length
    console.log "attempting to find open areas of size #{size}" if Busyverse.debug and Busyverse.verbose

    nearby_cells = @allCellsWithin(max_distance_from_center, city.center())

    for cell in nearby_cells
      passable   = @isAreaPassable(cell.location.size) 
      if passable
        available  = city.availableForBuilding(cell.location, size) 
        if available
          accessible = @pathfinder.shortestPath(current_location, cell.location).length > 0
          console.log "Is cell #{cell.location}... accessible? #{accessible} --...passable? #{passable} --...available? #{available}"
          if accessible
            return cell.location
    return null

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

  nearestUnexploredCell: (cellCoords) =>
    closest = null
    min_dist = 10000

    @map.eachCell (cell) =>
      return if @isCellExplored(cell)
      distance = @geometry.euclideanDistance(cellCoords, cell.location) 
      if distance < min_dist 
        min_dist = distance
        closest = cell

    closest.location

  getPath: (source, target) => 
    @pathfinder.shortestPath source, target

  getCellAtCanvasCoords: (coords) =>
    @map.getCellAt(@canvasToMapCoordinates(coords))

  randomCell: => [ @random.valueInRange(@width), @random.valueInRange(@height) ]

  randomPassableCell: ->
    console.log "World#randomPassableCell"
    location = null
    until location && @map.isLocationPassable location #getCellAt(location).isPassable()
      location = @randomCell()
    location
  
  randomPassableCellAccessibleFrom: (source) ->
    console.log "World#randomPassableCellAccessibleFrom source=#{source}"
    location = null
    accessible = false 
    tries = 0
    until (location && accessible) || tries > 10
      location = @random.valueFromList(@allCellsWithin(10, source)).location # @randomPassableCell()
      accessible = @pathfinder.shortestPath(source, location).length > 0
      tries = tries + 1

    if tries > 10
      return null

    location

  randomLocation: ->
    location = [ Math.round(@random.valueInRange(@width)) * @cellSize,
                 Math.round(@random.valueInRange(@height)) * @cellSize ]
    location
