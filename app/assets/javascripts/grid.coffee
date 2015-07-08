class Busyverse.GridCell
  constructor: (@location, @color) ->

class Busyverse.Grid
  map: []
  constructor: (@width, @height) ->
    @build()

  build: =>
    for x in [0..@width]
      @map[x] = []
      for y in [0..@height]
        @map[x][y] = @createCellAt([x,y])

  createCellAt: (location) =>
    new Busyverse.GridCell(location, 'green')

  eachCell: (callbackFn) =>
    for x in [0..@width]
      for y in [0..@height]
        callbackFn(@map[x][y])

  getCellAt: (location) =>
    x = location[0]
    y = location[1]
    if x >= 0 && x < @width && y >= 0 && y < @height
      @map[x][y]
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


