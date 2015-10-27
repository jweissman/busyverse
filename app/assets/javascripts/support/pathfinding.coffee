#= require pathfinding/pathfinder

class Busyverse.Support.Pathfinding
  constructor: (@map) ->
  shortestPath: (source, target) =>
    pathfinder = new Busyverse.Pathfinder(@map, source, target)
    pathfinder.detectShortestPath()
