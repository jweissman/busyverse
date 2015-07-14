#= require support/geometry
#= require support/randomness

class Busyverse.GridCell
  constructor: (@location, @color) ->
    @geometry = new Busyverse.Support.Geometry()

  distanceFrom: (otherLocation) =>
    @geometry.euclideanDistance @location, otherLocation

  isPassable: =>
    passable = @color == 'green' || @color == 'lightgreen' || @color == 'darkgreen'
    #console.log "is #{@color} passable? #{passable}"
    passable

class Busyverse.Grid
  constructor: (@width, @height) ->
    @cells = []
    @random = new Busyverse.Support.Randomness()
    console.log "GENERATING GRID PLEASE WAIT :)"
    @build()
    @evolve()

  build: =>
    for x in [0..@width]
      @cells[x] = []
      for y in [0..@height]
        @cells[x][y] = @createCellAt([x,y])

  createCellAt: (location) =>
    color = @random.valueFromPercentageMap
      # 1:  'darkgrey'
      # 2:  'grey'
      # 3:  'white'
      # 4:  'lightgrey'
      # 8:  'grey'
      4:  'blue'
      5: 'lightblue'
      1: 'darkblue'
      2: 'lightgreen'
      3: 'green'
      10: 'darkgreen'
    new Busyverse.GridCell(location, color)

  randomColor: => @random.valueFromList [
    # 'darkgrey', 'grey', 'white', 'lightgrey', 
    'blue', 'lightblue', 'lightgreen', 'darkblue', 'green', 'darkgreen'
    #'darkblue', 'lightgreen'
  ]

  evolve: (depth=5) =>
    return if depth <= 0
    console.log "evolve depth=#{depth}"
    @eachCell (cell) => 
      cell.color = @random.valueFromPercentageMap
        1: @randomColor()
        20: cell.color
        80: @mostCommonNeighborColor(cell)
    @evolve(depth-1)

  mostCommonNeighborColor: (cell) =>
    neighbors = @getAllNeighbors(cell.location)
    colors = []
    for neighbor in neighbors
      colors.push(neighbor.color)

    # find mode...
    most_common_color = null
    color_counts = {}
    for color in colors
      color_counts[color] ?= 0
      color_counts[color] = color_counts[color] + 1
      if most_common_color == null || color_counts[color] > color_counts[most_common_color]
        most_common_color = color

    most_common_color

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
  getCellToEastOf:  (location) => @getCellAt([location[0] + 1, location[1]])
  getCellToWestOf:  (location) => @getCellAt([location[0] - 1, location[1]])

  getCellToNorthwestOf: (location) => @getCellAt([location[0] - 1, location[1] - 1])
  getCellToNortheastOf: (location) => @getCellAt([location[0] + 1, location[1] - 1])

  getCellToSouthwestOf: (location) => @getCellAt([location[0] - 1, location[1] + 1])
  getCellToSoutheastOf: (location) => @getCellAt([location[0] + 1, location[1] + 1])
  
  getCellsAround: (location) =>
    [ 
      @getCellToNorthOf(location),
      @getCellToEastOf(location),
      @getCellToWestOf(location),
      @getCellToSouthOf(location),
    ].filter (elem) -> elem != null

  getLocationsAround: (loc) =>
    # console.log "getting cells around #{loc}"
    around = []
    neighbors = # @getCellsAround(loc) 
      @getAllNeighbors(loc)
    for cell in neighbors
      if cell.isPassable()
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
