class Busyverse.BuildingType
  @all: []
  constructor: (opts) ->
    { @name, @size, @color, @cost, @description, @stackable } = opts
    @stackable = @stackable == 'TRUE'
    @costs = { 'wood': @cost }
    Busyverse.BuildingType.all.push @
