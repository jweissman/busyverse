class Busyverse.Engine
  constructor: ->
    @game = new Busyverse.Game()
    @ui   = new Busyverse.Presenter(@game) #Busyverse.game)

  run: ->
    @canvas = document.getElementById('busyverse')
    
    # Turn the lights on
    @ui.attach(@canvas)
    @ui.render()
    
    # Kick game engine
    @game.play()


