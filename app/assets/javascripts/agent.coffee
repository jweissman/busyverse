#= require busyverse

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
class Busyverse.FindPathCommandHandler
  @handle: (command) ->
    console.log "FindPathCommandHandler.handle"
    console.log command
    
    { src, tgt } = command
    map = JSON.parse command.map

    { width, height, cellSize } = Busyverse

    w = width/cellSize
    h = height/cellSize
    grid = new Busyverse.Grid(w,h,map)
    pathfinder = new Busyverse.Support.Pathfinding(grid)

    console.log "---> Finding shortest path from #{src} to #{tgt}..."
    path = pathfinder.shortestPath(src, tgt)
    console.log "---* Found it!"

    # event to emit...
    type = 'path_found'
    { type, path }

# event-handlers are invoked by the agent that receives the event
# (the resultant events from the command)
class Busyverse.PathFoundEventHandler
  constructor: (@agent) ->
  handle: (event) =>
    console.log "PathFoundEventHandler#handle"
    console.log event

    { path } = event.data
    @agent.path = path
    @agent.recomputing = false
    #if path && path.length > 1
    #  @agent.destination = @computeDestination(path)
    #else
    #  @agent.path = null
    #  @agent.destinationCell = null


class Busyverse.Agent
  constructor: (@id, @name, @position) ->
    console.log "(New agent #{@name} created)"

    @pathFoundEventHandler = new Busyverse.PathFoundEventHandler(@)

    @backgroundWorker = Busyverse.createWorker()
    @backgroundWorker.onmessage = @handleEvent
    @backgroundWorker.onerror = @handleErrorCondition

  # this is 'our' handler, which handles the
  # events/messages sent by the worker below ...
  handleEvent: (event) =>
    console.log "Agent#handleEvent"
    { type, data } = event

    console.log "--> Agent #{@name} (#{@id}) handling event #{type} with data: "
    console.log data

    # handle result of shortestPath ...
    @pathFoundEventHandler.handle event

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

  # we could write other methods
  # that depend on callbacks!
  #
  # if we do this for the language-oriented commands too...
  # it might help simplify the engine!
  #
  # and we could do it for world-based things too....

