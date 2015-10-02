Array::remove = (from, to) ->
  rest = @slice((to or from) + 1 or @length)
  @length = if from < 0 then @length + from else from
  @push.apply @, rest

Array::equals = (b) ->
  @length is b.length and @every (elem, i) -> elem is b[i]

class Busyverse.Pathfinder
  constructor: (@map, @source, @target) ->
    console.log "Pathfinder.new" if Busyverse.trace
    @geometry = new Busyverse.Support.Geometry()
    @dist = {}
    @prev = {}
    @unvisited = []

    console.log @map if Busyverse.debug

    @map.eachCell (cell) =>
      @dist[cell.location] = Infinity
      @prev[cell.location] = null
      @unvisited.push(cell.location)

    @dist[@source] = 0
    @current = null

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
    for neighbor in @unvisitedNeighbors()
      alt = @dist[@current] + @geometry.euclideanDistance(@current, neighbor)
      if alt < @dist[neighbor]
        @dist[neighbor] = alt
        @prev[neighbor] = @current

  unvisitedNeighbors: =>
    neighbors = @map.getLocationsAround(@current)
    neighbors.filter (n) => n in @unvisited

  foundTarget: ->
    @current && @current.equals @target

  shouldTerminate: ->
    @unvisited.length == 0 || @foundTarget()

  assemblePath: =>
    sequence = []
    curr = @target
    while @prev[curr]
      sequence.push(curr)
      curr = @prev[curr]
    sequence.push(curr)
    sequence.reverse()

  detectShortestPath: =>
    until @shouldTerminate()
      nextCell = @closestUnvisited()
      return [] if nextCell == null
      @visit nextCell
    @assemblePath()
 
class Busyverse.Support.Pathfinding
  constructor: (@map) ->

  shortestPath: (source, target) =>
    pathfinder = new Busyverse.Pathfinder(@map, source, target)
    pathfinder.detectShortestPath()

Busyverse.findPath = (data) ->
  map = JSON.parse data.map

  h = Busyverse.width / Busyverse.cellSize
  w = Busyverse.height / Busyverse.cellSize
  grid = new Busyverse.Grid(h, w, map)

  path_finder = new Busyverse.Support.Pathfinding(grid)
  path = path_finder.shortestPath data.src, data.tgt

  msg = {
    personId: data.personId
    path: path
  }

  msg

