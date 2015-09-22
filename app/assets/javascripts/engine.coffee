class Busyverse.Engine
  constructor: (@game) ->
    @game ?= new Busyverse.Game()
    @ui   = new Busyverse.Presenter()

  setup: -> @game.setup()

  run: ->
    @canvas = document.getElementById('busyverse')

    if typeof(jQuery) == 'undefined'
      console.log "--- warning: jQuery is undefined!" if Busyverse.debug
    else
      $('#terminal').submit @handleCommand
     
    # Turn the lights on
    @ui.attach(@canvas)
    @canvas.addEventListener 'mousedown', @handleClick
     
    # Kick game engine
    @game.play(@ui)
    
    people = @game.world.city.population
    options = $('#target')
    options.append $('<option />').val(-1).text('all')
    $.each people, -> options.append $('<option />').val(@id).text(@name)
     
    console.log "Playing game!" if Busyverse.debug

  handleClick: (event) => @game.click(@ui.renderer.projectedMousePos, event)

  handleCommand: (event) =>
    command = $("input:first").val()

    result = @game.send command, $('#target').val()

    if Busyverse.debug
      console.log "Sent command #{command} to game with result #{result}" 
    $("span#response").text(result)

    event.preventDefault()
    return


