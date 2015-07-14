#= require support/randomness
#= require support/geometry
#= require buildings/farm

class Busyverse.Person
  size: [8,8]
  speed: 5
  visionRadius: 7
  velocity: [0,0]

  constructor: (@name, @position, @activeTask) ->
    @position   ?= [0,0]
    @random     ?= new Busyverse.Support.Randomness()
    @geometry   ?= new Busyverse.Support.Geometry()

    @activeTask ?= "idle"

    console.log "new person (#{@name}) created at #{@position} with task #{@activeTask}" if Busyverse.debug

  send: (cmd, city, world) => 
    console.log "updating #{@name}'s active task to #{cmd}" if Busyverse.debug

    if cmd == "wander" or cmd == "idle" or cmd == "build" # or cmd == "explore"
      if cmd == "build" # pick destination (and maybe building type?)
        @buildingToCreate = new Busyverse.Buildings.Farm()
        openAreas = world.findOpenAreasOfSizeInCity(city, @buildingToCreate.size)

        if openAreas.length == 0
          return "NO OPEN AREAS FOR BUILDING"
        @destinationCell = @random.valueFromList(openAreas)
        # @destination = world.mapToCanvasCoordinates(@destinationCell)
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

    else if @activeTask == "explore"
      @explore(world, city)

    else if @activeTask == "build"
      @build(world, city)

    if @activeTask != "idle"
      @move(world, city) 

  move: (world, city) =>
    @position[0] = @position[0] + @velocity[0]
    @position[1] = @position[1] + @velocity[1]

    world.markExploredSurrounding(
      world.canvasToMapCoordinates(@position),
      @visionRadius
    )

  build: (world, city) =>
    @seek(world)
    if @atSoughtLocation()
      console.log "CREATING BUILDING #{@buildingToCreate.name} at #{@buildingToCreate.position}" if Busyverse.debug
      city.create(@buildingToCreate)
      # @destination = null
      @activeTask  = "idle" 

  mapPosition: (world) => world.canvasToMapCoordinates(@position)

  pickWanderDestinationCell: (world, city) ->
    return world.randomPassableCell() #randomLocation() 

  wander: (world, city) =>
    @destinationCell ?= @pickWanderDestinationCell(world, city)
    @velocity    = [0,0]

    console.log "#{@name} wandering to #{@destinationCell}" if Busyverse.verbose
    @seek(world)
    if @atSoughtLocation()
      @destinationCell = @pickWanderDestinationCell(world, city)

  atSoughtLocation: () =>
    return false unless @destination
    distance = @geometry.euclideanDistance @position, @destination
    distance < 1

  arrayEqual: (a, b) ->
    a.length is b.length and a.every (elem, i) -> elem is b[i]

  updatePath: (world) ->
    srcCell  = world.getCellAtCanvasCoords @position
    destCell = world.map.getCellAt @destinationCell

    if srcCell == destCell
      return

    recompute = false
    if @path && @path.length > 1 && @arrayEqual(@path[@path.length-1], @destinationCell)
      unless @path[0] == srcCell.location
        @path.splice(0, @path.indexOf(srcCell.location))
      if @path.length > 0
        @destination = world.mapToCanvasCoordinates(@path[1])
      else 
        recompute = true
    else
      recompute = true

    if recompute
      console.log "RECOMPUTE PATH TO #{@destinationCell}"
      @path = world.getPath(srcCell.location, destCell.location)
      @destination = world.mapToCanvasCoordinates(@path[1])

  seek: (world) =>
    @updatePath(world)
    # @destination = world.mapToCanvasCoordinates @destinationCell

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

