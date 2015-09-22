#= require views/view

# palette of buildings
class Busyverse.Views.BuildingView extends Busyverse.View
  render: (world) =>
    building = @model

    if Busyverse.trace
      console.log "rendering building at #{building.position} of size #{building.size}" 

    pos  = world.mapToCanvasCoordinates(building.position)
    size = world.mapToCanvasCoordinates building.size

    @rect position: pos, size: size, fill: building.color

