#= require views/view

class Busyverse.Views.PersonView extends Busyverse.View
  render: (x,y) =>
    console.log "rendering person details at #{x}, #{y}" if Busyverse.verbose
    # write name and current task
    @renderName(x,y)

  renderName: (x, y) =>
    person = @model
    ox = x + 45.5
    oy = y - 55.5
    
    @rect
      position: [ox, oy]
      size: [130, 64]
      fill: 'whitesmoke'
      stroke: 'black'

    @text
      position: [ox + 10, oy + 24]
      size: '24px'
      msg: person.name

    @rect
      position: [ox + 10, oy + 32]
      size: [110, 24]
      fill: 'blanchedalmond'
      stroke: 'black'

    @text
      position: [ox + 66, oy + 50]
      size: '20px'
      msg: person.activeTask
      align: 'center'

