#= require support/geometry
#= require support/randomness

class Busyverse.GridCell
  constructor: (@location, @color) ->
    @geometry = new Busyverse.Support.Geometry()

  distanceFrom: (otherLocation) =>
    @geometry.euclideanDistance @location, otherLocation


class Busyverse.Grid
  constructor: (@width, @height) ->
    @cells = []
    @random = new Busyverse.Support.Randomness()
    @build()

  build: =>
    for x in [0..@width]
      @cells[x] = []
      for y in [0..@height]
        @cells[x][y] = @createCellAt([x,y])

  createCellAt: (location) =>
    color = @random.valueFromList(['lightgreen', 'green', 'darkgreen'])
    new Busyverse.GridCell(location, color)

  eachCell: (callbackFn) =>
    for x in [0..@width]
      for y in [0..@height]
        callbackFn(@cells[x][y])

  getCellAt: (location) =>
    x = location[0]
    y = location[1]
    if x >= 0 && x <= @width && y >= 0 && y <= @height
      @cells[x][y]
    else
      null

  getCellToNorthOf: (location) => @getCellAt([location[0], location[1] - 1])
  getCellToSouthOf: (location) => @getCellAt([location[0], location[1] + 1])

  getCellToEastOf: (location) => @getCellAt([location[0] + 1, location[1]])
  getCellToWestOf: (location) => @getCellAt([location[0] - 1, location[1]])
  
  getCellsAround: (location) =>
    [ @getCellToNorthOf(location),
      @getCellToEastOf(location),
      @getCellToWestOf(location),
      @getCellToSouthOf(location) ].filter (elem) -> elem != null #'undefined'


