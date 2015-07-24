#= require views/view

class Busyverse.Views.PersonView extends Busyverse.View
  render: =>
    person = @model

    console.log "rendering person at #{person.position}" if Busyverse.verbose

    @rect 
      position: @position(),
      size: @size(),
      fill: 'white',
      stroke: 'black'

    # write name and current task
    console.log ("rendering name etc") if Busyverse.verbose

    @renderDestination()
    @renderName()

  renderName: =>
    person = @model

    x = person.position[0]
    y = person.position[1]

    @rect
      position: [x+30, y-15]
      size: [100, 38]
      fill: 'lightblue'
      stroke: 'black'

    @text
      position: [x+35, y+2]
      size: '18px'
      msg: person.name

    @rect
      position: [x+34, y+6]
      size: [92, 14]
      fill: 'lightgreen'
      stroke: 'black'

    @text
      position: [x+38, y+17]
      size: '12px'
      msg: person.activeTask

  renderDestination: =>
    #console.log "PersonView#renderDestination"
    world = Busyverse.engine.game.world
    person = @model
    halfsize = [person.size[0] / 2, person.size[1]/2]
    offset = [ (Busyverse.cellSize / 2) - halfsize[0] / 2, (Busyverse.cellSize / 2) - halfsize[1] / 2 ]

    if typeof(person.path) != 'undefined' && person.path != null && person.path.length > 0
      for cell in person.path
        target = world.mapToCanvasCoordinates(cell, offset)
        # console.log "RENDERING PATH ELEMENT at target=#{target} (cell=#{cell}, offset=#{offset})"

        @rect
          position: target
          size: halfsize #person.size / 2
          fill: 'lightyellow'
          stroke: 'black'

    if typeof(person.destinationCell) != 'undefined' && person.destinationCell != null
      target = world.mapToCanvasCoordinates(person.destinationCell, offset)
      
      @rect
        position: target 
        size: halfsize #person.size
        fill: 'darkorange'
        stroke: 'black'

    # if typeof(person.destination) != 'undefined' && person.destination != null
    #   target = person.destination #world.mapToCanvasCoordinates(person.destinationCell, offset)
    #   
    #   @rect
    #     position: target 
    #     size: person.size
    #     fill: 'darkred'
    #     stroke: 'black'

      # msg = "Target for #{person.name}"
      # width = @textWidth
      #   msg: msg
      #   size: '14px'

      # @rect
      #   position: [target[0] + 12, target[1] - 4]
      #   size: [width + 8, 20]
      #   fill: 'darkred'
    
      # @text
      #   position: [target[0] + 15, target[1] + 10]
      #   msg: msg
      #   size: '14px'
      #   fill: 'red'



