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
    console.log "City#center -- finding center of #{@buildings.length} buildings"
    xs = 0
    ys = 0
    for building in @buildings
      console.log "considering building at #{building.position}"
      xs = xs + building.position[0]
      ys = ys + building.position[1]
    center = ([( xs / @buildings.length), (ys / @buildings.length )])
    console.log "-----> center: "
    console.log center
    center

  grow: (world) =>
    name     = @random.valueFromList [
      "Bob", "Amy", "John", "Kevin", "Tom", "Alex", "Brad", "Carrie", "Sofia", "Elisabeth", "Luka", "Gabriel",
      "Alain", "Ferris", "Orff", "Enoch", "Carol", "Sam", "Deborah", "Liam", "Thiago", "Elias", "Sem",
      "George", "Gina", "Dean", "Sarah", "Cindy", "Terrence", "Clark", "Karim", "Isabel", "William", "Aya",
      "Ana", "Amelie", "Augustine", "Aaron", "Anton", "Andre", "Anders", "Ahmed", "Emma", "Lucas",
      "Allard", "Artemis", "Stephanie", "Estrella", "Simon", "Paul", "Gilles", "Mia", "Anya", "Jen",
      "Felix", "Jean-Paul", "Michel", "Antoine", "Mohamed", "Fatima", "Juan", "Ali", "Hiroto", "Eden", "Maria"
    ]
    
    position = if world then world.mapToCanvasCoordinates(@center()) else [0,0]
    task     = "wander" #@random.valueFromList [ "wander", "explore" ]
    id = @population.length

    person = new Busyverse.Person(id, name, position, task)

    @population.push(person)

  update: (world) =>
    for person in @population
      person.update(world, @)
    
  create: (structure) =>
    console.log "creating new building [name=#{structure.name}]" if Busyverse.debug and Busyverse.verbose
    @buildings.push(structure)

  indicateAccessible: (location) =>
    console.log "City#indicateAccessible [location=#{location}]" if Busyverse.debug and Busyverse.verbose

    @accessible[location[0]] ?= []
    @accessible[location[0]][location[1]] = true
  
  isAccessible: (location) =>
    if @accessible[location[0]] && @accessible[location[0]][location[1]]
      true
    else
      false

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

