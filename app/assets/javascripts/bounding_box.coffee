#= require busyverse

class Busyverse.BoundingBox
  constructor: (@name, @position, @size) ->
  hit: (pos) =>
    @position[0] <= pos[0] <= @position[0] + @size[0] &&
    @position[1] <= pos[1] <= @position[1] + @size[1]
