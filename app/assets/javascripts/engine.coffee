#= require jquery

class Busyverse.Engine
  constructor: (@game, @ui) ->
    @game ?= new Busyverse.Game()
    @ui   ?= new Busyverse.Presenter()

  setup: ->
    @game.setup()
    
    @canvas = document.getElementById('busyverse')

    # Turn the lights on
    @ui.attach(@canvas)

    if @canvas != null
      @canvas.addEventListener 'mousedown', @handleClick
    else
      console.log "--- warning: canvas is null" if Busyverse.debug

    $('#terminal').submit @handleCommand
    people = @game.world.city.population
    options = $('#target')
    options.append $('<option />').val(-1).text('all')
    $.each people, -> options.append $('<option />').val(@id).text(@name)
     
  run: -> @game.play(@ui)

  handleClick: (event) => @game.click(@ui.renderer.projectedMousePos, event)

  handleCommand: (event) =>
    command = $("input:first").val()

    result = @game.send command, $('#target').val()

    if Busyverse.debug
      console.log "Sent command #{command} to game with result #{result}"
    $("span#response").text(result)

    event.preventDefault()
    return

  @instrument: ->
    engine = new Busyverse.Engine()
    engine.setup()
    window.onload = -> engine.run()
    engine

# kickstart fn
Busyverse.kickstart = ->
  Busyverse.engine = Busyverse.Engine.instrument()
  true
