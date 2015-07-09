#= require support/randomness

class Busyverse.World
  cellSize: 20
  constructor: (@width, @height) ->
    @width  ?= 20
    @height ?= 15
    @random = new Busyverse.Support.Randomness()
    @map = new Busyverse.Grid(@width, @height)
    console.log("Created new #{@width}x#{@height} world!") if Busyverse.debug

  canvasToMapCoordinates: (canvasCoords) =>
    x = canvasCoords[0] / @cellSize
    y = canvasCoords[1] / @cellSize

    [ Math.round(x), Math.round(y) ]

  mapToCanvasCoordinates: (mapCoords) =>
    console.log "Converting #{mapCoords} to canvas coords..."
    x = mapCoords[0] * @cellSize
    y = mapCoords[1] * @cellSize

    result = [ Math.round(x), Math.round(y) ]
    console.log "RESULT OF CONVERSION: #{result}"
    result

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

  markExploredSurrounding: (cellCoords) =>
    @markExplored(cellCoords)
    for cell in @map.getCellsAround(cellCoords)
      @markExplored(cell.location)
    
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
