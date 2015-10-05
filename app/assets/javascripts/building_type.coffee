class Busyverse.BuildingType
  @all: []
  constructor: (opts) ->
    { @name, @size, @color, @cost, @description, @stackable } = opts
    @costs = { 'wood': @cost }
    Busyverse.BuildingType.all.push @
