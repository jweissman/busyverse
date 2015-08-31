#= require support/geometry
#= require support/randomness

class Busyverse.GridCell
  constructor: (@location, @color) ->

class Busyverse.Grid
  constructor: (@width, @height, @cells, distribution) ->
    @cells ?= []
    @random = new Busyverse.Support.Randomness()
    
  setup: (distribution, evolve=true) =>
    @build(distribution)
    @evolve()
    @decorate()

  build: (distribution) =>
    for x in [0..@width]
      @cells[x] = []
      for y in [0..@height]
        @cells[x][y] = @createCellAt([x,y], distribution)

  createCellAt: (location, distribution) =>
    color = @random.valueFromPercentageMap distribution
    new Busyverse.GridCell(location, color)

  # start moving all this to world?
  evolve: (depth=6, noise=true) =>
    return if depth <= 0
    console.log "evolve depth=#{depth}"
    @eachCell (cell) => 
      cell.color = @random.valueFromPercentageMap
        25: if noise then 'darkgreen' else @mostCommonNeighborColor(cell)
        30: cell.color
        35: @mostCommonNeighborColor(cell)
    # @decorate() if noise
    @evolve(depth-1, !noise)

  decorate: =>
    @eachCell (cell) => 
      land  = @countNeighborsWithColor(cell, 'darkgreen') 

      if land > 5
        cell.color = @random.valueFromPercentageMap
          20: cell.color
          15: 'darkgreen'

      blue = @countNeighborsWithColor(cell, 'darkblue')

      if blue > 4
        cell.color = @random.valueFromPercentageMap
          20: cell.color
          15: 'darkblue'
          # 10: 'navy'
          # 5: 'midnightblue'
          # 4: 'mediumblue'
          # 3: 'lightyellow'
          # 2: 'grey'

      # surroundingColor = @mostCommonNeighborColor(cell)
      # if surroundingColor 
      #cell.color = @random.valueFromPercentageMap
      #  15: if noise then 'green' else @mostCommonNeighborColor(cell)
      #  45: cell.color
      #  40: @mostCommonNeighborColor(cell)

  countNeighborsWithColor: (cell, color) =>
    matching = @getAllNeighbors(cell.location).filter (n) => n.color == color
    matching.length

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

  isLocationPassable: (loc) =>
    cell = @getCellAt loc
    return false unless cell
    cell.color == 'green' || cell.color == 'forestgreen' || cell.color == 'darkgreen'

  getLocationsAround: (loc) =>
    # console.log "getting cells around #{loc}"
    around = []
    neighbors = # @getCellsAround(loc) 
      @getAllNeighbors(loc)
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
