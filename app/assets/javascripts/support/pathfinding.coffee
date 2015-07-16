Array::remove = (from, to) ->
  rest = @slice((to or from) + 1 or @length)
  @length = if from < 0 then @length + from else from
  @push.apply @, rest

Array::equals = (b) ->
    @length is b.length and @every (elem, i) -> elem is b[i]

class Busyverse.Pathfinder
  constructor: (@map, @source, @target) ->
    console.log "Pathfinder#new src=#{@source} tgt=#{@target}"
    # console.log @map
    @geometry = new Busyverse.Support.Geometry()
    @dist = {}
    @prev = {}
    @unvisited = []

    @map.eachCell (cell) =>
      # console.log cell
      @dist[cell.location] = Infinity
      @prev[cell.location] = null
      @unvisited.push(cell.location)

    @dist[@source] = 0
    @current = null
    @measured = [@source]

  closestUnvisited: =>
    smallestUnivisitedDistance = Infinity
    closest = null
    potentialUnvisited = @unvisited.filter (u) => @dist[u] < Infinity

    for u in potentialUnvisited
      unvisitedWeight = @dist[u]
      if unvisitedWeight < smallestUnivisitedDistance 
        smallestUnivisitedDistance = unvisitedWeight 
        closest = u
    closest

  visit: (cell) =>
    @current = cell
    @unvisited.remove(@unvisited.indexOf(@current))

  unvisitedNeighbors: =>
    neighbors = @map.getLocationsAround(@current)
    neighbors.filter (n) => n in @unvisited

  foundTarget: -> 
    @current && @current.equals @target 

  detectShortestPath: =>
    until @unvisited.length == 0 || @foundTarget()
      nextCell = @closestUnvisited()
      return [] if nextCell == null
      @visit nextCell
      for neighbor in @unvisitedNeighbors()
        alt = @dist[@current] + @geometry.euclideanDistance(@current, neighbor)
        if alt < @dist[neighbor]
          @dist[neighbor] = alt
          @prev[neighbor] = @current
          @measured.push neighbor
    
  assemblePath: =>
    sequence = []
    curr = @target
    while @prev[curr]
      sequence.push(curr)
      curr = @prev[curr]
    sequence.push(curr)
    sequence.reverse()

class Busyverse.Support.Pathfinding
  constructor: (@map) ->
    console.log "Pathfinding#new map -->"
    console.log @map

  shortestPath: (source, target) =>
    console.log "Pathfinding#shortestPath src=#{source}, tgt=#{target}"
    console.log @map

    pathfinder = new Busyverse.Pathfinder(@map, source, target)

    pathfinder.detectShortestPath()
    pathfinder.assemblePath()

Busyverse.findPath = (data) ->
  console.log "Busyverse.findPath"
  console.log data
  map = JSON.parse data.map
  console.log map
  grid = new Busyverse.Grid(Busyverse.width / Busyverse.cellSize, Busyverse.height / Busyverse.cellSize, map)

  (new Busyverse.Support.Pathfinding(grid)).shortestPath data.src, data.tgt

