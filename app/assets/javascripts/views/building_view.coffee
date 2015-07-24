#= require views/view

class Busyverse.Views.BuildingView extends Busyverse.View
  render: (world) =>
    # console.log "BUILDING VIEW #render"
    building = @model

    if Busyverse.trace # and Busyverse.verbose
      console.log "rendering building at #{building.position} of size #{building.size}" 

    # @context.fillStyle = building.color
    pos  = world.mapToCanvasCoordinates(building.position)
    size = world.mapToCanvasCoordinates building.size

    @rect position: pos, size: size, fill: building.color

    # @context.fillRect(
    #   ( building.position[0] * world.cellSize ),
    #   ( building.position[1] * world.cellSize ),
    #   ( building.size[0]     * world.cellSize ) # - 1,
    #   ( building.size[1]     * world.cellSize ) # - 1
    # )

    # console.log "rendered #{building.name} at #{building.position}"
