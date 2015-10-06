#= require busyverse
#= require person

class Busyverse.City
  name: "Busyville"
  explored: []

  constructor: (@population, @buildings) ->
    @population   ?= []
    @buildings    ?= []

    @resources     = { 'food': 10, 'wood': 100, 'iron': 0, 'gold': 0 }
    @random = new Busyverse.Support.Randomness()

    if Busyverse.verbose
      console.log "New city created with population #{@population}!"

  radiusOfInfluence: => 2 + (3 * @population.length)

  center: =>
    if Busyverse.debug
      console.log "City#center"
      console.log "-- finding center of #{@buildings.length} buildings"
    xs = 0
    ys = 0
    for building in @buildings
      xs = xs + building.position[0]
      ys = ys + building.position[1]
    center = ([( xs / @buildings.length), (ys / @buildings.length )])
    center

  addResource: (resource) =>
    @resources[resource.name] = @resources[resource.name] + 1

  grow: (world, position) =>
    name     = @random.valueFromList Busyverse.humanNames
    nameIndex = Busyverse.humanNames.indexOf(name)
    Busyverse.humanNames.splice(nameIndex,1)
    
    position ?= if world then world.mapToCanvasCoordinates(@center()) else [0,0]
    id       = @population.length

    person = new Busyverse.Person(id, name, position, task)
    task     = "wander"

    person.send(task, world)
    @population.push(person)
    Busyverse.engine.onPeopleCreated()

  update: (world) =>
    for person in @population
      person.update(world, @)

  canAfford: (structure) =>
    for resource of structure.costs
      return false if @resources[resource] < structure.costs[resource]
    true
    
  create: (structure, world=Busyverse.engine.game.world) =>
    if Busyverse.trace
      console.log "City.create -- creating new #{structure.name}"
      console.log "               at #{structure.position}"
    return false unless @canAfford(structure)

    for resource of structure.costs
      @resources[resource] -= structure.costs[resource]

    pos = [structure.position[0]*Busyverse.cellSize,
           structure.position[1]*Busyverse.cellSize]
    @grow(world, pos) if structure.subtype == 'residential'

    @buildings.push structure

  indicateAccessible: (location) =>
    if Busyverse.trace
      console.log "City#indicateAccessible [location=#{location}]"

    @accessible[location[0]] ?= []
    @accessible[location[0]][location[1]] = true
  
  isAccessible: (location) =>
    if @accessible[location[0]] && @accessible[location[0]][location[1]]
      true
    else
      false
  
  allExploredLocations: => @exploredLocations ||= []


  explore:    (location) =>
    if Busyverse.trace
      console.log "City#explore [location=#{location}]"
    @explored[location[0]] ?= []
    @explored[location[0]][location[1]] = true

    @exploredLocations ||= []
    @exploredLocations.push(location)

    @newlyExploredLocations ||= []
    @newlyExploredLocations.push(location)

  getNewlyExploredLocations: =>
    locations = @newlyExploredLocations
    @newlyExploredLocations = []
    locations

  isExplored: (location) =>
    return false unless location

    if @explored[location[0]] && @explored[location[0]][location[1]]
      true
    else
      false
    
  isAreaFullyExplored: (location, size) =>
    if Busyverse.trace
      console.log "City#isAreaFullyExplored [loc=#{location}, size=#{size}]"
    for x in [0..size[0]]
      for y in [0..size[1]]
        shifted_location = [location[0] + x, location[1] + y]
        if !@isExplored(shifted_location)
          return false
    true

  stackHeight: (location) =>
    height = 0
    for building in @buildings
      if building.position[0] == location[0] &&
         building.position[1] == location[1]
        height = height + 1
    height
    

  shouldNewBuildingBeStacked: (location, building_size, building_name) =>
    for building in @buildings
      if building.doesOverlap(location, building_size)
        { position, name, stackable } = building
        if position[0] == location[0] &&
           position[1] == location[1] &&
           name == building_name && stackable
          return true
    return false

  availableForBuilding: (location, sz, nm) =>
    return false unless @isAreaFullyExplored(location, sz)
    for building in @buildings
      if building.doesOverlap(location, sz)
        { position, name, stackable } = building
        if position[0] == location[0] && position[1] == location[1] &&
               name == nm && stackable
          return true
        else
          return false

    true
