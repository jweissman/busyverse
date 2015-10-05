#= require busyverse

class Busyverse.Building
  constructor: (@position, @type) ->
    @position[2] ?= 0
    { @name, @color, @size, @costs, @stackable } = @type

  doesOverlap: (location, sz) ->
    a_x1 = location[0]
    a_x2 = location[0] + sz[0]

    a_y1 = location[1]
    a_y2 = location[1] + sz[1]

    b_x1 = @position[0]
    b_x2 = @position[0] + @size[0]

    b_y1 = @position[1]
    b_y2 = @position[1] + @size[1]

    overlaps = (a_x1 < b_x2 && a_x2 > b_x1) &&
               (a_y1 < b_y2 && a_y2 > b_y1)
    overlaps

  @generate: (name, location) ->
    if Busyverse.trace
      console.log "Building.generate type=#{name} at #{location}"
    matching = Busyverse.BuildingType.all.filter (type) -> type.name == name
    matchingType = matching[0]

    building = new Busyverse.Building(location, matchingType)
    building
