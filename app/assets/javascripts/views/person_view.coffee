#= require views/view

class Busyverse.Views.PersonView extends Busyverse.View
  render: =>
    person = @model

    console.log "rendering person at #{person.position}" if Busyverse.verbose
    @context.fillStyle='darkblue'
    @context.fillRect(
      parseInt( person.position[0] ),
      parseInt( person.position[1] ),
      parseInt( person.size[0]     ),
      parseInt( person.size[1]     ) 
    )

    # write name and current task
    console.log ("rendering name etc") if Busyverse.verbose

    @context.fillStyle = "blue"
    @context.font = "bold 16px Arial"
    @context.fillText person.name, person.position[0] + 10, person.position[1] + 10
    @context.fillText person.activeTask, person.position[0] + 20, person.position[1] + 40

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


