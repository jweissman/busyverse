#= require busyverse
#= require person

class Busyverse.City
  name: "Busyville"
  explored: []

  constructor: (@population, @buildings) ->
    @population   ?= []
    @buildings    ?= []

    @resources     = { 'food': 10, 'wood': 10, 'iron': 0, 'gold': 0 }
    @random = new Busyverse.Support.Randomness()

    if Busyverse.verbose
      console.log "New city created with population #{@population}!" 

  detectIdleOrWanderingPerson: =>
    for person in @population
      if person.activeTask == 'idle' || person.activeTask == 'wander'
        return person

  center: =>
    if Busyverse.debug
      console.log "City#center -- finding center of #{@buildings.length} buildings" 
    xs = 0
    ys = 0
    for building in @buildings
      xs = xs + building.position[0]
      ys = ys + building.position[1]
    center = ([( xs / @buildings.length), (ys / @buildings.length )])
    center

  addResource: (resource) =>
    @resources[resource.name] = @resources[resource.name] + 1

  grow: (world) =>
    name     = @random.valueFromList [
      "Alain", 
      "Ferris", 
      "Orff", 
      "Enoch", 
      "Carol", 
      "Sam", 
      "Deborah", "Liam", "Thiago", "Elias", "Sem",
      "Allard", "Artemis", "Stephanie", "Estrella", "Simon", "Paul", "Gilles", "Mia", "Anya", "Jen",
      "Ana", "Amelie", "Augustine", "Aaron", "Anton", "Andre", "Anders", "Ahmed", "Emma", "Lucas",
      "Bob", "Amy", "John", "Kevin", "Tom", "Alex", "Brad", "Carrie", "Sofia", "Elisabeth", "Luka", "Gabriel",
      "Felix", "Jean-Paul", "Michel", "Antoine", "Mohamed", "Fatima", "Juan", "Ali", "Hiroto", "Eden", "Maria", "Lisbet"
      "George", "Gina", "Dean", "Sarah", "Cindy", "Terrence", "Clark", "Karim", "Isabel", "William", "Aya",
    ]
    
    position = if world then world.mapToCanvasCoordinates(@center()) else [0,0]
    id       = @population.length

    person = new Busyverse.Person(id, name, position, task)
    task     = "wander" #@random.valueFromList [ "wander" ] #, "gather", "build" ]

    person.send(task, world)

    @population.push(person)

  update: (world) =>
    for person in @population
      person.update(world, @)

  canAfford: (structure) =>
    for resource of structure.costs
      return false if @resources[resource] < structure.costs[resource]
    true
    
  create: (structure) =>
    console.log "creating new building [name=#{structure.name}]" if Busyverse.debug and Busyverse.verbose
    return false unless @canAfford(structure)

    for resource of structure.costs
      @resources[resource] -= structure.costs[resource]

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
    return false unless location
    # console.log "determining if location #{location} is explored...?"
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

