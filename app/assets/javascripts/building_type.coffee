class Busyverse.BuildingType
  @all: []
  constructor: (opts) ->
    { @name, @size, @color, @cost, @description, @stackable, @subtype } = opts
    @stackable = @stackable == 'TRUE'
    @costs = { 'wood': @cost }
    Busyverse.BuildingType.all.push @
