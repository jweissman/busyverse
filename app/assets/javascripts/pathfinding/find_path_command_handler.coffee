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
