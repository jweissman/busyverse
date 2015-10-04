class Busyverse.BuildingType
  @all: []
  constructor: (opts) ->
    { @name, @size, @color, @cost, @description } = opts
    @costs = { 'wood': @cost }
    Busyverse.BuildingType.all.push @
