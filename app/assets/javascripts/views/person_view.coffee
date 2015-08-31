#= require views/view

class Busyverse.Views.PersonView extends Busyverse.View
  render: (x,y) =>
    console.log "rendering person details at #{x}, #{y}" if Busyverse.verbose
    # write name and current task
    @renderName(x,y)

  renderName: (x, y) =>
    person = @model
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

