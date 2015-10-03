#= require views/view

class Busyverse.Views.SplashView extends Busyverse.View
  render: =>
    @text 
      msg: 'Please stand by.'
      position: [500,500]
      fill: 'white'


