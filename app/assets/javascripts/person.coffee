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
    #if msg.type == 'worker_result'
    #  console.log "GOT WORKER RESULT: "
    #  console.log msg
    #  console.log msg.result
    if msg.type == 'user_command'
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

  # pickWanderDestinationCell: (world) -> #, city) ->
  #   @destinationCell ?= world.randomCell() # @pickWanderDestinationCell(world, city)
  #   # console.log "Person#pickWanderDestinationCell"
  #   # dest = world.randomCell() #randomPassableCellAccessibleFrom(@position) #randomLocation() 
  #   # #  world.randomPassableCellAccessibleFrom(@mapPosition(world)) #world.canvasToMapCoordinates(@position))
  #   # console.log "Found dest => #{dest}"
  #   # dest

  wander: (world, city) =>
    # console.log "Person#wander"
    @destinationCell ?= world.randomCell() # @pickWanderDestinationCell(world, city)
    @velocity         = [0,0]

    console.log "#{@name} wandering to #{@destinationCell}" if Busyverse.verbose

    @seek(world)
    # if @atSoughtLocation(world)
    #   console.log "Person#wander ---> At sought location (#{@destination}), picking new wander target" 
    #   @destinationCell = @pickWanderDestinationCell(world, city)

  atSoughtLocation: (world) =>
    return false unless @destinationCell
    distance = @geometry.euclideanDistance @position, world.mapToCanvasCoordinates(@destinationCell)
    distance < 1

  arrayEqual: (a, b) ->
    a.length is b.length and a.every (elem, i) -> elem is b[i]

  updatePath: (world) ->
    # console.log "Person#updatePath"
    return unless @destinationCell

    srcCell  = world.getCellAtCanvasCoords @position
    destCell = world.map.getCellAt @destinationCell

    if srcCell == destCell
      return

    recompute = false

    if @path && @path.length > 1 && @arrayEqual(@path[@path.length-1], @destinationCell)
      console.log "--- we have a path, but where are we on it?"
      console.log "---> path: "
      console.log @path
      console.log "---> my position: "
      console.log @position
      console.log "srcCell.location => #{srcCell.location}"
      unless @arrayEqual(@path[0], srcCell.location)
        console.log "---> we are not on the *first* cell, splicing..."
        matches = @path.filter (n) => @arrayEqual(n, srcCell.location)
        src_index = @path.indexOf(matches[0])#srcCell.location)
        console.log "---> where is #{srcCell.location}? #{src_index}"
        @path.splice(0, src_index)
        console.log "---> path is spliced"

      if @path.length > 0
        console.log "---> the path is not empty, set @destination to next cell"
        nextTarget = world.mapToCanvasCoordinates(@path[1])
        @destination = nextTarget
      else 
        recompute = true
    else
      recompute = true

    @recomputing ?= false
    # console.log "--- recompute? #{recompute} (already recomputing? #{@recomputing})"
    if recompute && !@recomputing
      @recomputing = true
      @world = world # TODO please do pass into ctor

      #console.log world.map.cells
      console.log "POST MESSAGE -- RECOMPUTE"
      Busyverse.worker.postMessage
        map: JSON.stringify world.map.cells
        src: srcCell.location
        tgt: destCell.location
       
  handlePathResponse: (pathData) =>
    console.log "Person#handlePathResponse"
    @recomputing = false
    @path = pathData
    if @path && @path.length > 1
      console.log "GOT PATH! Setting destination..."
      @destination = @world.mapToCanvasCoordinates(@path[1])
      console.log "new destination = #{@destination}"
    else
      console.log "WARNING! @path was empty, setting path, destinationCell and destination to null..."
      # try to reset?
      @path = null
      @destinationCell = null

  seek: (world) =>
    console.log "Person#seek"
    # unless @target
    #   console.log "(no target, bailing)"
    #   return
    # console.log "---> Destination cell #{@target} ('real' target)"
    console.log "---> Current position #{@position}, current destination #{@destination}"

    #if !@path || @path.length == 0 || @atSoughtLocation(world) 
    console.log "===> updating path"
    @updatePath(world)
    console.log "--- done"
    unless @destination
      console.log "---> no destination, bailing"
      return


    # console.log "--- attempting to move towards destination #{@destination}"

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

