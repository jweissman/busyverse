class Busyverse.Views.WorldView extends Busyverse.View
  render: =>
    console.log "rendering world!" if Busyverse.debug and Busyverse.verbose

    world = @model

    world.map.eachCell (cell) =>
      @context.fillStyle = cell.color
      console.log "rendering world cell at #{cell.location}" if Busyverse.debug and Busyverse.verbose
      @context.fillRect(
        world.cellSize * cell.location[0], 
        world.cellSize * cell.location[1], 
        world.cellSize - 1, 
        world.cellSize - 1
      )
