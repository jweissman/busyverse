#= require busyverse
#= require pathfinding/find_path_command_handler
#= require pathfinding/path_found_event_handler

# basically we need a way to 'wrap' methods around workers
# to serialize the arguments etc
#
# we have achieved this with pathfinding, so we try to use this as a model
# and try to generalize the signal somewhat (even if we ultimately
# have to use a switch-case or something like that...)

# to formalize it, commands would be what we send to workers...
# and events would be what we get back!

# command-handlers should be static methods on an appropriately-named object
# (invoked by web workers)
# class Busyverse.FindPathCommandHandler
#   @handle: (command) ->
#     console.log "FindPathCommandHandler.handle"
#     console.log command
#
#     { src, tgt } = command
#     map = JSON.parse command.map
#
#     { width, height, cellSize } = Busyverse
#
#     w = width/cellSize
#     h = height/cellSize
#     grid = new Busyverse.Grid(w,h,map)
#     pathfinder = new Busyverse.Support.Pathfinding(grid)
#
#     console.log "---> Finding shortest path from #{src} to #{tgt}..."
#     path = pathfinder.shortestPath(src, tgt)
#     console.log "---* Found it!"
#
#     # event to emit...
#     type = 'path_found'
#     { type, path }

# event-handlers are invoked by the agent that receives the event
# (the resultant events from the command)
#    class Busyverse.PathFoundEventHandler
#      constructor: (@agent) ->
#      handle: (event) =>
#        console.log "PathFoundEventHandler#handle"
#        console.log event
#
#        { path } = event.data
#        @agent.path = path
#        @agent.recomputing = false

class Busyverse.BuildCommandHandler
  @handle: (command) ->
    console.log "BuildCommandHandler.handle"

    { map, influencedCells, buildingType } = command
    { size } = buildingType

    parsedMapCells = JSON.parse(map)
    parsedInfluencedCells = JSON.parse(influencedCells)

    console.log "---> Building size: #{size}"
    console.log "---> Parsed map: "
    console.log parsedMapCells
    console.log "---> Parsed influenced cells: "
    console.log parsedInfluencedCells

    #if city.resources['wood'] < 1
    #  return "you must have at least one wood to build!"
    until openArea
      #@buildingToCreate = @random.valueFromList Busyverse.BuildingType.all
      radius   = city.radiusOfInfluence()
      openArea = world.findOpenAreaOfSizeInCity(city, size, radius)

    type = 'destination_indicated'
    destination = openArea
    { type, destination }

    # @destinationCell = openArea
    # @buildingToCreatePosition = @destinationCell
    # if Busyverse.debug
    #   console.log "planning to build a #{@buildingToCreate}"
    #   console.log "         at #{@buildingToCreatePosition}"

class Busyverse.DestinationIndicatedEventHandler
  constructor: (@agent) ->
  handleEvent: (evt) ->
    console.log "DestinationIndicatedEventHandler#handleEvent"
    { destination } = evt
    @agent.destinationCell = @agent.buildToCreatePosition = destination

class Busyverse.Agent
  constructor: (@id, @name, @position) ->
    console.log "(New agent #{@name} created)"

    @eventHandlers = {
      path_found: new Busyverse.PathFoundEventHandler(@),
      destination_indicated: new Busyverse.DestinationIndicatedEventHandler(@)
    }

    # @pathFoundEventHandler = new Busyverse.PathFoundEventHandler(@)
    # @destinationIndicatedEventHandler =
    #   new Busyverse.DestinationIndicatedEventHandler(@)

    @backgroundWorker = Busyverse.createWorker()
    @backgroundWorker.onmessage = @handleEvent
    @backgroundWorker.onerror = @handleErrorCondition

  # this is 'our' handler, which handles the
  # events/messages sent by the worker below ...
  handleEvent: (event) =>
    console.log "Agent#handleEvent"
    { data } = event
    { type } = data

    console.log "--> Agent #{@name} (#{@id}) handling event #{type} with data: "
    console.log data

    handler = @eventHandlers[type]
    if handler?
      handler.handle(event)
    else

    # handle result of shortestPath ...
    # if type == 'path_found'
    #   @pathFoundEventHandler.handle event
    # else if type == 'destination_indicated'
    #   @destinationIndicatedEventHandler.handle event
    # else
      console.log "---> Agent #{@name} does not recognize event #{type}"

  # so this is the general static
  # message-handling method the
  # worker will call...
  @handleCommand: (command) ->
    console.log "Agent.handleCommand"
    { data } = command
    { type } = data

    console.log "--> Agent handling "
    console.log "    command #{type} with data: "
    console.log data
    # assume pathfinding for now
    # will need to multiplex on 'type' of command
    if type == 'find_shortest_path'
      Busyverse.FindPathCommandHandler.handle(data)
    else if type == 'build'
      Busyverse.BuildCommandHandler.handle(data)
    else
      console.log "---> Agent doesn't recognize command type #{type}"

  @handleErrorCondition: (error) ->
    console.log "--> Agent encountered an error: #{error}"

  # and this is how we invoke
  # these commands...
  sendCommand: (command) =>
    console.log "Agent#sendCommand"
    console.log "--> command:"
    console.log command

    #console.log @backgroundWorker

    # what should we validate?
    console.log "--- Creating background worker for agent #{@name}..."

    console.log "---> giving command to worker..."
    console.log @backgroundWorker

    @backgroundWorker.postMessage(command)

  # let's write a shortest method
  # that uses the web worker
  findShortestPathSoon: (src, tgt, world=Busyverse.engine.game.world) =>
    console.log "Agent#findShortestPathSoon src=#{src} tgt=#{tgt}"
    map = JSON.stringify(world.map.cells)
    type = 'find_shortest_path'
    @sendCommand { map, src, tgt, type }

  buildSoon: (buildingType) =>
    type = 'build'
    buildingType ?= @random.valueFromList Busyverse.BuildingType.all
    map = JSON.stringify(world.map.cells)
    influencedCells = JSON.stringify(world.city.influencedCells)

    @sendCommand { map, type, buildingType, influencedCells }

  # we could write other methods
  # that depend on callbacks!
  #
  # if we do this for the language-oriented commands too...
  # it might help simplify the engine!
  #
  # and we could do it for world-based things too....

