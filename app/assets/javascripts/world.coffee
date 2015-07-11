#= require support/randomness

class Busyverse.World
  cellSize: 10

  constructor: (@width, @height) ->
    @width  ?= 80
    @height ?= 60

    @random = new Busyverse.Support.Randomness()
    @map = new Busyverse.Grid(@width, @height)
    console.log("Created new #{@width}x#{@height} world!") if Busyverse.debug

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

  findOpenAreasOfSizeInCity: (city, size) =>
    open_areas = []
    console.log "attempting to find open areas of size #{size}" if Busyverse.debug and Busyverse.verbose
    @map.eachCell (cell) =>
      if city.availableForBuilding(cell.location, size)
        open_areas.push(cell.location)
    if Busyverse.debug and Busyverse.verbose
      console.log "Found open areas: " 
      console.log open_areas
    open_areas

  markExplored: (cellCoords) =>
    console.log "Marking #{cellCoords} explored" if Busyverse.debug and Busyverse.verbose
    cell = @map.getCellAt(cellCoords)
    if cell != null
      cell.color = 'lightgreen'

  isExplored: (cell) =>
    cell.color == 'lightgreen'

  markExploredSurrounding: (cellCoords) =>
    @markExplored(cellCoords)
    for cell in @map.getCellsAround(cellCoords)
      @markExplored(cell.location)

  nearestUnexploredCell: (cellCoords) =>
    closest = null
    min_dist = 10000

    @map.eachCell (cell) =>
      return if @isExplored(cell)
      dx = Math.abs(cellCoords[0] - cell.location[0])
      dy = Math.abs(cellCoords[1] - cell.location[1])
      distance = Math.sqrt( (dx*dx) + (dy*dy) )
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
    location = [ @random.valueInRange(@width * @cellSize), 
                 @random.valueInRange(@height * @cellSize) ]
    console.log "Using random location #{location}"
    location
