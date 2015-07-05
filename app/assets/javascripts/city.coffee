#= require busyverse
#= require person

class Busyverse.City
  constructor: (@population, @buildings) ->
    @population   ?= []
    @buildings    ?= []
    @_constructors = []
    console.log "New city created with population #{@population}!"

  grow: ->
    bob = new Busyverse.Person("Bob")
    @population.push(bob)

  update: =>
    console.log "--- Updating city!!"
    
  create: (structure) =>
    @buildings.push(structure)
 
