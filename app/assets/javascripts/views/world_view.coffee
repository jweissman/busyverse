class Busyverse.Views.WorldView extends Busyverse.View
  render: =>
    console.log "rendering world!" if Busyverse.trace
    world = @model

    world.map.eachCell (cell) => @renderCell(world, cell)

  renderCell: (world, cell) =>
    console.log 'considering cell:' if Busyverse.trace
    console.log cell if Busyverse.trace

    console.log "cell location: #{cell.location}" if Busyverse.trace
    location = cell.location

    console.log "is #{location} explored?" if Busyverse.trace
    explored = world.isCellExplored(cell)
    console.log "explored? #{explored}" if Busyverse.trace

    return unless explored
    color    = cell.color 
    console.log "chosen color: #{color}" if Busyverse.trace
    @context.fillStyle = color

    console.log "rendering world cell at #{cell.location} in color #{cell.color}" if Busyverse.trace
    console.log cell if Busyverse.trace

    x = world.cellSize * cell.location[0]
    y = world.cellSize * cell.location[1] 
    w = world.cellSize - 1
    h = world.cellSize - 1
 
    @context.fillRect(x, y, w, h)

    console.log "---> Drew #{w}x#{h} rect at #{x}, #{y} in #{color}" if Busyverse.trace
