class Busyverse.Views.WorldView extends Busyverse.View
  render: =>
    console.log "rendering world!" if Busyverse.debug
    world = @model

    world.map.eachCell (cell) => @renderCell(world, cell)

  renderCell: (world, cell) =>
    console.log "render cell" if Busyverse.debug
    console.log cell if Busyverse.debug
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
    # @context.fillStyle = color

    console.log "rendering world cell at #{cell.location} in color #{cell.color}" if Busyverse.trace
    console.log cell if Busyverse.trace

    x = Busyverse.cellSize * cell.location[0]
    y = Busyverse.cellSize * cell.location[1] 
    w = Busyverse.cellSize # - 1
    h = Busyverse.cellSize # - 1
 
    console.log "drawing rect at #{x}, #{y} and #{w}, #{h}" if Busyverse.trace
    @rect position: [x,y], size: [w,h], fill: color
    # @context.fillRect(x, y, w, h)

    console.log "---> Drew #{w}x#{h} rect at #{x}, #{y} in #{color}" if Busyverse.debug
