#= require views/view

class Busyverse.Views.BuildingView extends Busyverse.View
  render: (world) =>
    building = @model

    if Busyverse.debug and Busyverse.verbose
      console.log "rendering building at #{building.position} of size #{building.size}" 

    @context.fillStyle = building.color
    @context.fillRect(
      ( building.position[0] * world.cellSize ),
      ( building.position[1] * world.cellSize ),
      ( building.size[0] * world.cellSize ) - 1,
      ( building.size[1] * world.cellSize ) - 1
    )
