arrayUnique = (a) ->
  a.reduce ((p, c) ->
    if p.indexOf(c) < 0
      p.push c
    p
  ), []

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

  evolve: (map, depth=Busyverse.evolveDepth, noise=true) =>
    return if depth <= 0
    console.log "evolve depth=#{depth}" if Busyverse.debug
    map.eachCell (cell) =>
      cell.color = @random.valueFromPercentageMap
        80: cell.color
        20: @mostCommonNeighborColor(map, cell)
        #2:  'darkgreen'
    @evolve(map, depth-1, !noise)
    map

  countNeighborsWithColor: (map, cell, color) ->
    matching = map.getAllNeighbors(cell.location).
      filter (n) -> n.color == color
    matching.length

  mostCommonNeighborColor: (map, cell) ->
    neighbors = map.getAllNeighbors(cell.location)
    colors = []
    color_counts = {}
    for neighbor in neighbors
      colors.push(neighbor.color)

    most_common_color = null
    for color in arrayUnique colors
      color_counts[color] = @countNeighborsWithColor(map, cell, color)
      more_common = color_counts[color] > color_counts[most_common_color]
      if most_common_color == null || more_common
        most_common_color = color

    most_common_color
