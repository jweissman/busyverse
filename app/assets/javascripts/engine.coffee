#= require jquery

class Busyverse.Engine
  constructor: (@game, @ui) ->
    @game ?= new Busyverse.Game()
    @ui   ?= new Busyverse.Presenter()

  setup: ->
    console.log(Busyverse.banner)
    @game.setup()
    
    @canvas = document.getElementById('busyverse')

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

    document.onkeypress = (e) => @handleKeypress(e)
     
  run: -> @game.play(@ui)

  handleClick: (event) => @game.click(@ui.renderer.projectedMousePos, event)

  handleKeypress: (event) ->
    console.log "KEYPRESS"
    console.log event
    if event.keyCode == 61
      console.log "+"
      # i think we need to be able to 'reboot' the ui engine!
      #Busyverse.scale = Busyverse.scale * 2
      # @ui.attach(@canvas)

    else if event.keyCode == 45
      console.log "-"
      #Busyverse.scale = Busyverse.scale / 2
      # @ui.attach(@canvas)
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
