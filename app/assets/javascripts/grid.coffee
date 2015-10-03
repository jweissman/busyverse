#= require support/geometry
#= require support/randomness

class Busyverse.Grid
  constructor: (@width, @height, @cells) ->
    @random = new Busyverse.Support.Randomness()
    @cells ?= []

  eachCell: (callbackFn) =>
    for y in [0..@height]
      for x in [0..@width]
        callbackFn(@cells[x][y])

  allCells: =>
    allCells = []
    for x in [0..@width]
      for y in [0..@height]
        allCells.push(@cells[x][y])
    allCells

  getCellAt: (location) =>
    x = location[0]
    y = location[1]
    if x >= 0 && x <= @width && y >= 0 && y <= @height
      @cells[x][y]
    else
      null

  directions: ['north', 'south', 'east', 'west']

  getCellToNorthOf: (location) => @getCellAt([location[0], location[1] - 1])
  getCellToSouthOf: (location) => @getCellAt([location[0], location[1] + 1])
  getCellToEastOf:  (location) => @getCellAt([location[0] + 1, location[1]])
  getCellToWestOf:  (location) => @getCellAt([location[0] - 1, location[1]])

  getCellToNorthwestOf: (location) =>
    @getCellAt([location[0] - 1, location[1] - 1])
  getCellToNortheastOf: (location) =>
    @getCellAt([location[0] + 1, location[1] - 1])

  getCellToSouthwestOf: (location) =>
    @getCellAt([location[0] - 1, location[1] + 1])
  getCellToSoutheastOf: (location) =>
    @getCellAt([location[0] + 1, location[1] + 1])
  
  getCellsAround: (location) =>
    [
      @getCellToNorthOf(location),
      @getCellToEastOf(location),
      @getCellToWestOf(location),
      @getCellToSouthOf(location),
    ].filter (elem) -> elem != null

  isLocationPassable: (loc) =>
    cell = @getCellAt loc
    return false unless cell
    is_green = cell.color == 'green' ||
               cell.color == 'forestgreen' ||
               cell.color == 'darkgreen'
    return is_green

  getLocationsAround: (loc) =>
    around = []
    neighbors = @getAllNeighbors(loc)
    for cell in neighbors
      if @isLocationPassable(cell.location)
        around.push(cell.location)
    
    around

  getAllNeighbors: (location) =>
    [
      @getCellToNorthOf(location)
      @getCellToNorthwestOf(location)
      @getCellToNortheastOf(location)

      @getCellToEastOf(location)
      @getCellToWestOf(location)

      @getCellToSouthOf(location)
      @getCellToSoutheastOf(location)
      @getCellToSouthwestOf(location)
    ].filter (elem) -> elem != null
