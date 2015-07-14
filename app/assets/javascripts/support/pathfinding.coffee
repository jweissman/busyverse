Array::remove = (from, to) ->
  rest = @slice((to or from) + 1 or @length)
  @length = if from < 0 then @length + from else from
  @push.apply @, rest

#arrayEqual = (a, b) ->
Array::equals = (b) ->
    @length is b.length and @every (elem, i) -> elem is b[i]


class Busyverse.Support.Pathfinding
  constructor: (@map) ->
  shortestPath: (source, target) =>
    # console.log "---> finding shortest path from #{source} to #{target}"
    dist   = {}
    previous  = {}
    unvisited = []

    @geometry ||= new Busyverse.Support.Geometry()

    @map.eachCell (cell) =>
      dist[cell.location]  = Infinity
      previous[cell.location] = null
      unvisited.push(cell.location)

    dist[source] = 0

    until unvisited.length == 0 || (current && current.equals(target))
      smallestUnivisitedDistance = Infinity
      nextCell = null

      for u in unvisited
        unvisitedWeight = dist[u]
        if unvisitedWeight < smallestUnivisitedDistance 
          smallestUnivisitedDistance = unvisitedWeight 
          nextCell = u

      current = nextCell
      
      unvisited.remove(unvisited.indexOf(current))
      neighbors = @map.getLocationsAround(current)
      unvisitedNeighbors = neighbors.filter (n) => n in unvisited

      for neighbor in unvisitedNeighbors
        alternative_distance = dist[current] + @geometry.euclideanDistance(current, neighbor)
        if alternative_distance < dist[neighbor]
          dist[neighbor]     = alternative_distance
          previous[neighbor] = current
    
    sequence = []
    current = target

    while previous[current]
      sequence.push(current)
      current = previous[current]
    sequence.push(current)

    path = sequence.reverse()
    path



