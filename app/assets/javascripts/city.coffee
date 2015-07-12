#= require busyverse
#= require person

class Busyverse.City
  name: "Busyville"
  explored: []

  constructor: (@population, @buildings) ->
    @population   ?= []
    @buildings    ?= []
    @random = new Busyverse.Support.Randomness()
    console.log "New city created with population #{@population}!" if Busyverse.verbose

  center: =>
    xs = 0
    ys = 0
    for building in @buildings
      xs = xs + building.position[0]
      ys = ys + building.position[1]
    return([( xs / @buildings.length), (ys / @buildings.length )])

  grow: (world) =>
    name     = @random.valueFromList [
      "Bob", "Amy", "John", "Kevin", "Tom", "Alex", "Brad", "Carrie",
      "Alain", "Ferris", "Orff", "Enoch", "Carol", "Sam", "Deborah",
      "George", "Gina", "Dean", "Sarah", "Cindy", "Terrence", "Clark",
      "Ana", "Amelie", "Augustine", "Aaron", "Anton", "Andre", "Anders",
      "Allard", "Artemis", "Stephanie", "Estrella", "Simon", "Paul", "Gilles",
      "Felix", "Jean-Paul", "Michel", "Antoine"
    ]
    position = if world then world.mapToCanvasCoordinates(@center()) else [0,0]
    task     = @random.valueFromList [ "wander", "explore" ]

    person = new Busyverse.Person(name, position, task)

    @population.push(person)

  update: (world) =>
    for person in @population
      person.update(world, @)
    
  create: (structure) =>
    console.log "creating new building [name=#{structure.name}]" if Busyverse.debug and Busyverse.verbose
    @buildings.push(structure)

  explore:    (location) => 
    console.log "City#explore [location=#{location}]" if Busyverse.debug and Busyverse.verbose
    @explored[location[0]] ?= []
    @explored[location[0]][location[1]] = true

  isExplored: (location) => 
    if @explored[location[0]] && @explored[location[0]][location[1]]
      true
    else
      false
    
  isAreaFullyExplored: (location, size) => 
    console.log "City#isAreaFullyExplored [location=#{location}, size=#{size}]" if Busyverse.debug and Busyverse.verbose
    for x in [0..size[0]]
      for y in [0..size[1]]
        shifted_location = [location[0] + x, location[1] + y]
        if !@isExplored(shifted_location)
          return false
    true

  availableForBuilding: (location, size) =>
    return false unless @isAreaFullyExplored(location, size)

    for building in @buildings
      if building.doesOverlap(location, size)
        return false

    true

