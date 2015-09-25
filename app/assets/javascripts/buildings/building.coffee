#= require busyverse

class Busyverse.Building
  costs:
    'wood': 2
  size : [1,1,1]
  constructor: (@position) ->
    console.log "--- creating new building at #{@position}" if Busyverse.debug

  doesOverlap: (location, size) ->
    a_x1 = location[0]
    a_x2 = location[0] + size[0]
    a_y1 = location[1]
    a_y2 = location[1] + size[1]
    b_x1 = @position[0]
    b_x2 = @position[0] + @size[0]
    b_y1 = @position[1]
    b_y2 = @position[1] + @size[1]
    a_x1 < b_x2 && a_x2 > b_x1 && a_y1 < b_y2 && a_y2 > b_y1

  @all: -> [ new Busyverse.Buildings.Farm(), 
             new Busyverse.Buildings.House(), 
             new Busyverse.Buildings.Tower() ]

  @generate: (name, location) ->
    console.log "generating building of type #{name} at #{location}" if Busyverse.debug
    building = null
    if name == 'Small Farm'
      building = new Busyverse.Buildings.Farm(location)
    else if name == 'Residence'
      building = new Busyverse.Buildings.House(location)
    else if name == 'Large Tower'
      building = new Busyverse.Buildings.Tower(location)
    building
