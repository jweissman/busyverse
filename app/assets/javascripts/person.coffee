#= require support/randomness
#= require support/geometry
#= require buildings/farm

class Busyverse.Person
  size: [8,8]
  speed: 2.5
  visionRadius: 7
  velocity: [0,0]

  constructor: (@name, @position, @activeTask) ->
    @position   ?= [0,0]
    @random     ?= new Busyverse.Support.Randomness()
    @geometry   ?= new Busyverse.Support.Geometry()

    @activeTask ?= "idle"

    console.log "new person (#{@name}) created at #{@position} with task #{@activeTask}" if Busyverse.debug

  send: (msg, city, world) => 
    console.log "Person#send"
    if msg.type == 'worker_result'
      console.log "GOT WORKER RESULT: "
      console.log msg
      console.log msg.result
    else if msg.type == 'user_command'
      console.log "updating #{@name}'s active task to #{cmd}" if Busyverse.debug
      cmd = msg.operation

      if cmd == "wander" or cmd == "idle" or cmd == "build" # or cmd == "explore"
        if cmd == "build" # pick destination (and maybe building type?)
          console.log "BUILD COMMAND RECEIVED"
          @buildingToCreate = new Busyverse.Buildings.Farm()
          console.log "Finding open areas..."
          openArea = world.findOpenAreaOfSizeInCity(city, @buildingToCreate.size, 2*city.population.length, @mapPosition(world))
          console.log "Got open areas: "
          console.log openArea
          if openArea == null #s.length == 0
            return "NO OPEN AREAS FOR BUILDING"
          @destinationCell = openArea # k@random.valueFromList(openAreas)
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
    console.log "Person#pickWanderDestinationCell"
    dest = #world.randomCell() #randomPassableCellAccessibleFrom(@position) #randomLocation() 
      world.randomPassableCellAccessibleFrom(@mapPosition(world)) #world.canvasToMapCoordinates(@position))
    console.log "Found dest => #{dest}"
    dest

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
    return unless @destinationCell
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
       
      # @path = world.getPath(srcCell.location, destCell.location)
      # if @path && @path.length > 1
      #   @destination = world.mapToCanvasCoordinates(@path[1])

      console.log world.map.cells
      Busyverse.worker.postMessage
        map: JSON.stringify world.map.cells
        src: srcCell.location
        tgt: destCell.location
       

  seek: (world) =>
    @updatePath(world)
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

