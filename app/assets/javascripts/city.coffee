#= require busyverse
#= require person

class Busyverse.City
  name: "Busyville"
  constructor: (@population, @buildings) ->
    @population   ?= []
    @buildings    ?= []
    @_constructors = []
    console.log "New city created with population #{@population}!" if Busyverse.verbose

  center: =>
    xs = 0
    ys = 0
    for building in @buildings
      xs = xs + building.position[0]
      ys = ys + building.position[1]
    return([( xs / @buildings.length), (ys / @buildings.length )])

  grow: (world) =>
    bob = new Busyverse.Person("Bob", world.mapToCanvasCoordinates(@center()), "wander")
    @population.push(bob)

  update: (world) =>
    console.log "--- Updating city!!" if Busyverse.verbose
    for person in @population
      person.update(world, @)
    
  create: (structure) =>
    console.log "creating new building" if Busyverse.debug
    console.log structure
    @buildings.push(structure)

  availableForBuilding: (location, size) =>
    for building in @buildings
      if building.doesOverlap(location, size)
        return false
    true

