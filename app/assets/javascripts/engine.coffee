class Busyverse.Engine
  constructor: ->
    @game = new Busyverse.Game()
    @ui   = new Busyverse.Presenter()

  run: ->
    @canvas = document.getElementById('busyverse')

    if typeof(jQuery) == 'undefined'
      console.log "--- jQuery is undefined!" if Busyverse.debug
    else
      $('#terminal').submit (event), @handleCommand
    
    # Turn the lights on
    @ui.attach(@canvas)
    
    # Kick game engine
    console.log "Playing game!" if Busyverse.debug
    @game.play(@ui)

  handleCommand: (event) =>
    command = $("input:first").val()

    result = @game.send(command)
    console.log "Sent command #{command} to game with result #{result}" if Busyverse.debug

    event.preventDefault()
    return


