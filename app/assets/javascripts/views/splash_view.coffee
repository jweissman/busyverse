#= require views/view

class Busyverse.Views.SplashView extends Busyverse.View
  render: =>
    @text
      msg: "Busyverse"
      position: [100,600]
      size: '80px'
      fill: 'white'
      style: 'bold'

    @text
      msg: Busyverse.version
      position: [520,602]
      size: '30px'
      fill: 'orange'

    @text
      msg: 'Deep Cerulean Games and Simulations'
      position: [100,655]
      size: '50px'
      fill: 'lightblue'

    msg_index = 0
    for message in Busyverse.loadingMessages
      @text
        msg: message
        position: [100,700 + msg_index*26]
        size: '24px'
        fill: 'steelblue'
      msg_index += 1
       
