#= require busyverse

class Busyverse.City
  constructor: (@population, @buildings) ->
    @population ?= 0
    @buildings ?= []
    @_constructors = []
    console.log "New city created with population #{@population}!"

  grow: ->
    @population = @population + 1

  update: =>
    console.log "--- Updating city!!"
    
  create: (structure) =>
    @buildings.push(structure)
 
