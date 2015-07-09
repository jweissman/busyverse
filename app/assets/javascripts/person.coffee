#= require support/randomness
#= require buildings/farm

class Busyverse.Person
  size: [10,10]
  speed: 10
  velocity: [0,0]

  constructor: (@name, @position, @activeTask) ->
    @position   ?= [0,0]
    @activeTask ?= "idle"
    @random     ?= new Busyverse.Support.Randomness()
    console.log "new person (#{@name}) created at #{@position}" if Busyverse.debug

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
      @wander(world)

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
      @activeTask = "idle"

  wander: (world) =>
    @destination ?= world.randomLocation()
    @velocity    = [0,0]

    console.log "#{@name} heading to #{@destination}" if Busyverse.verbose
    @seek()
    if @atSoughtLocation()
      @destination = world.randomLocation()

  atSoughtLocation: () =>
    dx = Math.abs(@destination[0] - @position[0])
    dy = Math.abs(@destination[1] - @position[1])
    distance = Math.sqrt( (dx*dx) + (dy*dy) )
    distance < (2*@speed)

  seek: () =>
    # console.log "SEEKING"
    if @destination[0] < @position[0] - @speed
      @velocity[0] = -@speed
    else if @destination[0] > @position[0] + @speed
      @velocity[0] = @speed
    else
      @velocity[0] = 0
    
    if @destination[1] < @position[1] - @speed
      @velocity[1] = -@speed
    else if @destination[1] > @position[1] + @speed
      @velocity[1] = @speed
    else
      @velocity[1] = 0

