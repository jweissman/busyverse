#= require support/randomness
#= require support/geometry
#= require agent

class Busyverse.Person extends Busyverse.Agent
  size: [0.45,0.45,1.6]
  mapSize: [5,9]
  speed: 2.0
  visionRadius: Busyverse.defaultVisionRadius
  velocity: [0,0]
  color: { red: 150, green: 170, blue: 210 }

  constructor: (@id, @name, @position) ->
    @position   ?= [0,0]
    @random     ?= new Busyverse.Support.Randomness()
    @geometry   ?= new Busyverse.Support.Geometry()

    @activeTask = "idle"
    @recomputing = false

    if Busyverse.debug
      console.log "new person (#{@id} -- #{@name}) created at #{@position}"
      console.log "current task is #{@activeTask}"
    super(@id, @name, @position)

  send: (msg, world=Busyverse.engine.game.world) =>
    console.log "Person#send msg=#{msg}" if Busyverse.trace
    city = world.city
    console.log "updating #{@name}'s active task to #{cmd}" if Busyverse.debug
    cmd = msg

    if cmd == "wander" or cmd == "idle" or cmd == "build" or cmd == "gather"
      if cmd == "build"
        if city.resources['wood'] < 1
          return "you must have at least one wood to build!"
        until openArea
          @buildingToCreate = @random.valueFromList Busyverse.BuildingType.all
          { size } = @buildingToCreate
          radius   = city.radiusOfInfluence()
          openArea = world.findOpenAreaOfSizeInCity(city, size, radius)
        @destinationCell = openArea
        @buildingToCreatePosition = @destinationCell

        if Busyverse.debug
          console.log "planning to build a #{@buildingToCreate}"
          console.log "         at #{@buildingToCreatePosition}"

      else if cmd == "gather"
        console.log "GATHER COMMAND RECEIVED" if Busyverse.debug
        return "no resources to gather!" unless world.resources.length > 0
        chosen_resource = @pickResource world
        return "no resources under influence?!" unless chosen_resource
        @resourceToGather = chosen_resource
        @destinationCell  = @resourceToGather.position
        if Busyverse.debug
          name = @resourceToGather.name
          console.log "Gathering #{name} at #{@destinationCell}"

      @activeTask  = cmd
      return "#{@name} #{@activeTask}ing"

    else
      return "Unknown command #{cmd}"

  pickResource: (world) =>
    influencedResources = []
    for resource in (world.resources)
      for cell in world.city.influencedCells
        if resource.doesOverlap(cell.location, [1,1])
          influencedResources.push resource

    pos = [@position[0] / Busyverse.cellSize,
           @position[1] / Busyverse.cellSize ]
    sortedResources = influencedResources.sort (a,b) =>
      da = @geometry.euclideanDistance(a.position, pos)
      db = @geometry.euclideanDistance(b.position, pos)
      if da < db
        -1
      else if db < da
        1
      else
        0

    @random.valueFromList sortedResources[..5]

  update: (world, city) =>
    console.log "Person#update called!" if Busyverse.debug and Busyverse.verbose

    if @activeTask == "wander"
      @wander(world, city)

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
      { name } = @buildingToCreate
      pos = @buildingToCreatePosition
      bldg = Busyverse.Building.generate(name, pos)
      world.tryToBuild(bldg, true)
      @send 'build'

  gather: (world, city) =>
    if world.resources.length == 0
      @send('idle')
      return

    @seek(world)

    if @atSoughtLocation(world)
      if world.resources.indexOf(@resourceToGather)
        world.resources.remove(world.resources.indexOf(@resourceToGather))
        city.addResource @resourceToGather
      if world.resources.length > 0
        @send 'gather'
      else
        @send 'idle'

  mapPosition: (world) => world.canvasToMapCoordinates(@position)

  pickWanderDestinationCell: (world, city) =>
    pos = @mapPosition(world)
    nearbyCell = world.nearbyUnexploredCell(pos, 1 + (@visionRadius) ) ||
                 world.nearbyUnexploredCell(pos, 2 + (@visionRadius*5) ) ||
                 world.nearbyCell(pos, 3 + (@visionRadius*2))
    nearbyCell

  wander: (world, city) =>
    @destinationCell ?= @pickWanderDestinationCell(world, city)
    @velocity         = [0,0]

    @seek(world)
    if @atSoughtLocation(world)
      @path = null
      @destinationCell = @pickWanderDestinationCell(world, city)

  atSoughtLocation: (world) =>
    return false unless @destinationCell

    x_off = (Busyverse.cellSize / 2) - @mapSize[0] / 2
    y_off = (Busyverse.cellSize / 2) - @mapSize[1] / 2
    offset = [ x_off, y_off ]

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

    more_path_left = @path && @path.length > 0

    if more_path_left && @arrayEqual(@path[@path.length-1], @destinationCell)
      x_off = (Busyverse.cellSize / 2) - @mapSize[0] / 2
      y_off = (Busyverse.cellSize / 2) - @mapSize[1] / 2
      offset = [ x_off, y_off ]
      nextTarget = world.mapToCanvasCoordinates(@path[0], offset)
      distance = @geometry.euclideanDistance(nextTarget, @position)

      if distance <= @speed * 2
        matches   = @path.filter (n) => @arrayEqual(n, srcCell.location)
        src_index = @path.indexOf(matches[0])
        @path.splice(0, src_index+1)

      if @path.length >= 1
        x_off = (Busyverse.cellSize / 2) - @mapSize[0] / 2
        y_off = (Busyverse.cellSize / 2) - @mapSize[1] / 2
        offset = [ x_off, y_off ]
        nextTarget = world.mapToCanvasCoordinates(@path[0], offset)
        @destination = nextTarget
      else
        recompute = true
    else
      recompute = true

    if recompute && !@recomputing
      @recomputing = true
     
      console.log "POST MESSAGE -- RECOMPUTE" if Busyverse.verbose
      @findShortestPathSoon srcCell.location, destCell.location

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

