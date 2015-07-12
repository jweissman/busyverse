#= require support/randomness
#= require grid
#= require city

class Busyverse.World
  name: 'Busylandia'
  cellSize: 10

  constructor: (@width, @height) ->
    @width   ?= 200
    @height  ?= 200
    @city     = new Busyverse.City()
    @map      = new Busyverse.Grid(@width, @height)
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

  findOpenAreasOfSizeInCity: (city, size, max_distance_from_center) =>
    open_areas = []
    max_distance_from_center ?= 3*city.population.length
    console.log "attempting to find open areas of size #{size}" if Busyverse.debug and Busyverse.verbose

    nearby_cells = @allCellsWithin(max_distance_from_center, city.center())

    for cell in nearby_cells
      if city.availableForBuilding(cell.location, size)
        open_areas.push(cell.location)

    if Busyverse.debug and Busyverse.verbose
      console.log "Found open areas: " if Busyverse.debug
      console.log open_areas if Busyverse.debug

    open_areas
  
  allCellsWithin: (maxDistance, center, callbackFn) =>
    cellsInRadius = []
    @map.eachCell (cell) =>
      if cell.distanceFrom(center) <= maxDistance
        cellsInRadius.push(cell)
    cellsInRadius

  markExplored: (cellCoords) => 
    console.log "World#markExplored [coords=#{cellCoords}]" if Busyverse.debug
    @city.explore(cellCoords) unless @isLocationExplored(cellCoords)

  isCellExplored: (cell) => @city.isExplored(cell.location)
  isLocationExplored: (location) => @city.isExplored(location)

  markExploredSurrounding: (cellCoords, depth=4) =>
    @markExplored(cellCoords) unless @isLocationExplored(cellCoords)
    return if depth <= 0
    for cell in @map.getCellsAround(cellCoords)
      @markExploredSurrounding(cell.location, depth-1) if cell

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
    
  randomCell: ->
    console.log("Finding random location")
    location = [ @random.valueInRange(@width), @random.valueInRange(@height) ]
    console.log "Using random location #{location}"
    location

  randomLocation: ->
    console.log("Finding random location")
    location = [ Math.round(@random.valueInRange(@width)) * @cellSize,
                 Math.round(@random.valueInRange(@height)) * @cellSize ]
    console.log "Using random location #{location}"
    location
