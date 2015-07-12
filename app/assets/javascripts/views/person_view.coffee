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

    x = person.position[0]
    y = person.position[1]
    w = person.size[0]
    h = person.size[1]

    @context.beginPath()
    @context.rect @x() + 30, @y() - 15, 100, 35
    @context.fillStyle = 'lightblue'
    @context.fill()
    @context.lineWidth = 2
    @context.strokeStyle = 'black'
    @context.stroke()


    # write name and current task
    console.log ("rendering name etc") if Busyverse.verbose
    @renderName()

  renderName: =>
    person = @model

    x = person.position[0]
    y = person.position[1]

    @context.beginPath()
    @context.rect x + 30, y - 15, 100, 35
    @context.fillStyle = 'lightblue'
    @context.fill()
    @context.lineWidth = 2
    @context.strokeStyle = 'black'
    @context.stroke()

    @context.fillStyle = "black"
    @context.font = "bold 16px Arial"
    @context.fillText person.name, x + 35, y # person.position[0] + 10, person.position[1] + 10

    @context.beginPath()
    @context.rect x + 34, y + 3, 92, 13
    @context.fillStyle = 'lightgreen'
    @context.fill()
    @context.lineWidth = 1
    @context.strokeStyle = 'black'
    @context.stroke()

    @context.fillStyle = "black"
    @context.font = "bold 10px Arial"
    @context.fillText person.activeTask, x + 38, y + 13 #person.position[0] + 20, person.position[1] + 40

    # @renderDestination()

  renderDestination: =>
    person = @model
    if typeof(person.destination) != 'undefined' && person.destination != null
      @context.fillStyle="red"
      @context.fillRect(
        parseInt( person.destination[0] ),
        parseInt( person.destination[1] ),
        parseInt( person.size[0]     ),
        parseInt( person.size[1]     ) 
      )

      @context.fillStyle = "red"
      @context.font = "bold 18px Sans Serif"
      @context.fillText "#{person.name}'s destination", person.destination[0] + 10, person.destination[1] + 10


