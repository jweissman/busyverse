#= require busyverse
#= require person

class Busyverse.City
  name: "Busyville"
  constructor: (@population, @buildings) ->
    @population   ?= []
    @buildings    ?= []
    @_constructors = []
    console.log "New city created with population #{@population}!" if Busyverse.verbose

  grow: ->
    bob = new Busyverse.Person("Bob")
    @population.push(bob)

  update: (world) =>
    console.log "--- Updating city!!" if Busyverse.verbose
    for person in @population
      person.update(world, @)
    
  create: (structure) =>
    console.log "creating new building"
    console.log structure
    @buildings.push(structure)
 
