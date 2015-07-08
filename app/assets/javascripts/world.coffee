class Busyverse.Support.Randomness
  valueInRange: (range) ->
    Math.floor Math.random() * range

class Busyverse.World
  cellSize: 15
  constructor: (@width, @height) ->
    @width  ?= 60
    @height ?= 25
    @random = new Busyverse.Support.Randomness()
    @map = new Busyverse.Grid(@width, @height)
    console.log("Created new #{@width}x#{@height} world!") if Busyverse.debug

  canvasToMapCoordinates: (canvasCoords) =>
    x = canvasCoords[0] / @cellSize
    y = canvasCoords[1] / @cellSize

    [ Math.round(x), Math.round(y) ]

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
