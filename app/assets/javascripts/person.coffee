#= require support/randomness
#= require support/geometry
#= require buildings/farm

class Busyverse.Person
  size: [10,10]
  speed: 5
  velocity: [0,0]

  constructor: (@name, @position, @activeTask) ->
    @position   ?= [0,0]
    @random     ?= new Busyverse.Support.Randomness()
    @geometry   ?= new Busyverse.Support.Geometry()

    @activeTask ?= "idle"
    console.log "new person (#{@name}) created at #{@position} with task #{@activeTask}" if Busyverse.debug

  send: (cmd, city, world) => 
    console.log "updating #{@name}'s active task to #{cmd}" if Busyverse.debug

    if cmd == "wander" or cmd == "idle" or cmd == "build"
      @destination = null

      if cmd == "build" # pick destination (and maybe building type?)
        @buildingToCreate = new Busyverse.Buildings.Farm()
        openAreas = world.findOpenAreasOfSizeInCity(city, @buildingToCreate.size)

        if openAreas.length == 0
          return "NO OPEN AREAS FOR BUILDING"
        @destinationCell = @random.valueFromList(openAreas)
        @destination = world.mapToCanvasCoordinates(@destinationCell)
        @buildingToCreate.position = @destinationCell #.location
        console.log "BUILDING #{@buildingToCreate.name} AT #{@buildingToCreate.position}" if Busyverse.debug and Busyverse.verbose
      @activeTask  = cmd
      return "Now doing #{@activeTask}"

    else
      return "Unknown command #{cmd}"

  update: (world, city) =>
    console.log "Person#update called!" if Busyverse.debug and Busyverse.verbose

    if @activeTask == "wander"
      @wander(world, city)

    else if @activeTask == "build"
      @build(world, city)

    if @activeTask != "idle"
      @move(world, city) 

  move: (world, city) =>
    @position[0] = @position[0] + @velocity[0]
    @position[1] = @position[1] + @velocity[1]

    world.markExploredSurrounding(
      world.canvasToMapCoordinates(@position)
    )

  build: (world, city) =>
    @seek()
    if @atSoughtLocation()
      console.log "CREATING BUILDING #{@buildingToCreate.name} at #{@buildingToCreate.position}" if Busyverse.debug
      city.create(@buildingToCreate)
      @destination = null
      @activeTask  = "idle" 

  mapPosition: (world) => world.canvasToMapCoordinates(@position)

  pickWanderDestination: (world, city) ->
    nearestUnexploredFromCityCenter = world.nearestUnexploredCell(city.center()) 
    nearestUnexploredFromPerson     = world.nearestUnexploredCell(@mapPosition(world))

    @random.valueFromList [
      world.mapToCanvasCoordinates(nearestUnexploredFromCityCenter),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson),
      world.mapToCanvasCoordinates(nearestUnexploredFromPerson)
    ]

  wander: (world, city) =>
    @destination ?= @pickWanderDestination(world, city)
    @velocity    = [0,0]

    console.log "#{@name} heading to #{@destination}" if Busyverse.verbose
    @seek()
    if @atSoughtLocation()
      @destination = @pickWanderDestination(world, city)

  atSoughtLocation: () =>
    return false unless @destination
    distance = @geometry.euclideanDistance @position, @destination
    distance <  1

  seek: () =>
    return unless @destination
    if @destination[0] < @position[0]
      @velocity[0] = -@speed
    else if @destination[0] > @position[0]
      @velocity[0] = @speed
    else
      @velocity[0] = 0
    
    if @destination[1] < @position[1]
      @velocity[1] = -@speed
    else if @destination[1] > @position[1]
      @velocity[1] = @speed
    else
      @velocity[1] = 0

