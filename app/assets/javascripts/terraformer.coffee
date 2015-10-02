class Busyverse.Terraformer
  constructor: () ->
    @random = new Busyverse.Support.Randomness()
   
  compose: (map, distribution, evolve=true) =>
    @generate map,distribution
    @evolve(map) if evolve
    map

  generate: (map, distribution) =>
    console.log "Terraformer#generate" if Busyverse.trace
    for x in [0..map.width]
      map.cells[x] = []
      for y in [0..map.height]
        map.cells[x][y] = @createCellAt([x,y], distribution)
    map

  createCellAt: (location, distribution) ->
    console.log "Terraformer#createCellAt #{location}" if Busyverse.trace
    color = @random.valueFromPercentageMap distribution
    { location: location, color: color }

  evolve: (map, depth=6, noise=true) =>
    return if depth <= 0
    console.log "evolve depth=#{depth}" if Busyverse.debug
    map.eachCell (cell) =>
      cell.color = @random.valueFromPercentageMap
        25: if noise then 'darkgreen' else @mostCommonNeighborColor(map, cell)
        30: cell.color
        35: @mostCommonNeighborColor(map, cell)
    @decorate(map) if noise
    @evolve(map, depth-1, !noise)
    map

  decorate: (map) =>
    map.eachCell (cell) =>
      land  = @countNeighborsWithColor(map, cell, 'darkgreen')

      if land > 7
        cell.color = @random.valueFromPercentageMap
          98: cell.color
          2: 'darkblue'

      blue = @countNeighborsWithColor(map, cell, 'darkblue')

      if blue > 7
        cell.color = @random.valueFromPercentageMap
          98: cell.color
          2: 'darkgreen'
    map

  countNeighborsWithColor: (map, cell, color) ->
    matching = map.getAllNeighbors(cell.location).
      filter (n) -> n.color == color

    matching.length

  mostCommonNeighborColor: (map, cell) ->
    neighbors = map.getAllNeighbors(cell.location)
    colors = []
    for neighbor in neighbors
      colors.push(neighbor.color)

    most_common_color = null
    color_counts = {}
    for color in colors
      color_counts[color] ?= 0
      color_counts[color] = color_counts[color] + 1
      more_common = color_counts[color] > color_counts[most_common_color]
      if most_common_color == null || more_common
        most_common_color = color

    most_common_color



  

