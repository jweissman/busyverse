#= require support/randomness
#= require support/geometry
#= require buildings/farm

class Busyverse.Person
  size: [5,9]
  speed: 2.0
  visionRadius: 4
  velocity: [0,0]

  constructor: (@id, @name, @position) ->
    @position   ?= [0,0]
    @random     ?= new Busyverse.Support.Randomness()
    @geometry   ?= new Busyverse.Support.Geometry()

    @activeTask = "idle"

    console.log "new person (#{@id} -- #{@name}) created at #{@position} with task #{@activeTask}" # if Busyverse.debug

    # @send @activeTask

  send: (msg, world=Busyverse.engine.game.world) =>
    @activeTask = "idle"
    console.log "Person#send msg=#{msg}"
    city = world.city
    console.log "updating #{@name}'s active task to #{cmd}" if Busyverse.debug
    cmd = msg

    if cmd == "wander" or cmd == "idle" or cmd == "build" or cmd == "gather"
      if cmd == "build" 
        if city.resources['wood'] < 2
          return "A NEW FARM REQUIRES 2 WOOD"

        @buildingToCreate = new Busyverse.Buildings.Farm()
        openArea = world.findOpenAreaOfSizeInCity(city, @buildingToCreate.size, 2*city.population.length)
        if typeof(openArea) == 'undefined' || openArea == null
          
          return "NO OPEN AREAS FOR BUILDING"
        @destinationCell = openArea
        @buildingToCreate.position = @destinationCell #.location

        console.log "BUILDING #{@buildingToCreate.name} AT #{@buildingToCreate.position}" if Busyverse.debug and Busyverse.verbose

      else if cmd == "gather"
        console.log "GATHER COMMAND RECEIVED"
        resources = world.resources.filter (resource) =>
          world.isLocationExplored(resource.position)

        # world.resources.filter (resource) =>
        #   @geometry.euclideanDistance(resource.position, @position)
        if resources.length == 0
          return "NO VISIBLE RESOURCES TO GATHER"
        closest_resource = null
        min_dist = Infinity
        target = @random.valueFromPercentageMap
          20: city.center()
          80: @position
        console.log "finding resources closest to #{target}"

        sortedResources = resources.sort (a, b) =>
          return if @geometry.euclideanDistance(a.position, target) <= @geometry.euclideanDistance(b.position, target) then 1 else -1

        # for resource in resources
        #   dist = @geometry.euclideanDistance(resource.position, target)
        #   if dist < min_dist
        #     min_dist = dist
        #     closest_resource = resource

        @resourceToGather = @random.valueFromList(sortedResources[..4])
        @destinationCell  = @resourceToGather.position
        console.log "Gathering #{@resourceToGather.name} at #{@destinationCell}"

      @activeTask  = cmd
      return "#{@name} now performing '#{@activeTask}'"

    else
      return "Unknown command #{cmd}"

  update: (world, city) =>
    console.log "Person#update called!" if Busyverse.debug and Busyverse.verbose

    if @activeTask == "wander"
      @wander(world, city)

    # else if @activeTask == "explore"
    #   @explore(world, city)

    else if @activeTask == "build"
      @build(world, city)

    else if @activeTask == "gather"
      @gather(world, city)

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
    if @atSoughtLocation(world)
      console.log "CREATING BUILDING #{@buildingToCreate.name} at #{@buildingToCreate.position}" if Busyverse.debug
      city.create(@buildingToCreate)
      @send 'build'

  gather: (world, city) =>
    @seek(world)
    if @atSoughtLocation(world)
      console.log "GATHERING RESOURCE #{@resourceToGather.name}" if Busyverse.debug
      world.resources.remove(world.resources.indexOf(@resourceToGather))
      city.addResource @resourceToGather
      @send 'gather'
      # @activeTask = "idle"

  mapPosition: (world) => world.canvasToMapCoordinates(@position)

  pickWanderDestinationCell: (world, city) =>
    @random.valueFromPercentageMap
      40: world.nearbyUnexploredCell(@mapPosition(world),15)
      30: world.nearbyUnexploredCell(@mapPosition(world),30)
      25: world.randomPassableCell()

  wander: (world, city) =>
    @destinationCell ?= @pickWanderDestinationCell(world, city)
    @velocity         = [0,0]
    console.log "#{@name} wandering to #{@destinationCell}" if Busyverse.debug && Busyverse.verbose
    @seek(world)
    if @atSoughtLocation(world)
      console.log "Person#wander ---> At sought location (#{@destination}), could be picking new wander target" if Busyverse.debug
      @path = null
      @destinationCell = @pickWanderDestinationCell(world, city)

  atSoughtLocation: (world) =>
    return false unless @destinationCell
    offset = [ (Busyverse.cellSize / 2) - @size[0] / 2, (Busyverse.cellSize / 2) - @size[1] / 2 ]
    target = world.mapToCanvasCoordinates(@destinationCell, offset)
    distance = @geometry.euclideanDistance(@position, target)
    distance <= @speed*2

  arrayEqual: (a, b) ->
    a.length is b.length and a.every (elem, i) -> elem is b[i]

  updatePath: (world) ->
    return unless @destinationCell

    srcCell  = world.getCellAtCanvasCoords @position
    destCell = world.map.getCellAt @destinationCell

    if srcCell == destCell
      return

    recompute = false

    if @path && @path.length > 0 && @arrayEqual(@path[@path.length-1], @destinationCell)

      offset = [ (Busyverse.cellSize / 2) - @size[0] / 2, (Busyverse.cellSize / 2) - @size[1] / 2 ]
      nextTarget = world.mapToCanvasCoordinates(@path[0], offset)
      distance = @geometry.euclideanDistance(nextTarget, @position)
      if distance <= @speed * 2  # @size[1] #Busyverse.cellSize - @speed #@arrayEqual(@path[0], srcCell.location) && distance < 10 # @speed # * 2
        # console.log " ----> splicing path"
        # console.log # @speed
        matches   = @path.filter (n) => @arrayEqual(n, srcCell.location)
        src_index = @path.indexOf(matches[0])
        @path.splice(0, src_index+1)

      if @path.length >= 1
        offset = [ (Busyverse.cellSize / 2) - @size[0] / 2, (Busyverse.cellSize / 2) - @size[1] / 2 ]
        nextTarget = world.mapToCanvasCoordinates(@path[0], offset)
        @destination = nextTarget
      else if distance <= @speed * 2
      else
        recompute = true
    else
      recompute = true

    @recomputing ?= false
    if recompute && !@recomputing
      @recomputing = true
     
      console.log "POST MESSAGE -- RECOMPUTE" if Busyverse.verbose
      msg = {
        map: JSON.stringify world.map.cells
        src: srcCell.location
        tgt: destCell.location
        personId: @id
      }
      console.log msg

      @background_worker = Busyverse.createWorker()
      @background_worker.onmessage = (result) =>
        @handlePathResponse result.data.path
      @background_worker.postMessage msg
       
  handlePathResponse: (pathData) =>
    console.log "Person#handlePathResponse" if Busyverse.debug and Busyverse.verbose
    @recomputing = false
    @path = pathData
    if @path && @path.length > 1
      console.log "GOT PATH! Setting destination..." if Busyverse.verbose
      world = Busyverse.engine.game.world
      offset = [ (Busyverse.cellSize / 2) - @size[0] / 2, (Busyverse.cellSize / 2) - @size[1] / 2 ]
      @destination = world.mapToCanvasCoordinates(@path[1], offset)
      console.log "new destination = #{@destination}" if Busyverse.verbose
    else
      console.log "WARNING! @path was empty, setting path, destinationCell and destination to null..." if Busyverse.debug
      # try to reset?
      @path = null
      @destinationCell = null

  seek: (world) =>
    @updatePath(world)
    return unless @destination

    dx = Math.abs(@destination[0] - @position[0])
    dy = Math.abs(@destination[1] - @position[1])

    if dx >= @speed
      if @destination[0] < @position[0]
        @velocity[0] = -@speed
      else if @destination[0] > @position[0]
        @velocity[0] = @speed
    else
      @velocity[0] = 0
    
    if dy >= @speed
      if @destination[1] < @position[1] 
        @velocity[1] = -@speed
      else if @destination[1] > @position[1] 
        @velocity[1] = @speed
    else
      @velocity[1] = 0

