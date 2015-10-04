#= require jquery

class Busyverse.Engine
  constructor: (@game, @ui) ->
    @game ?= new Busyverse.Game()
    @ui   ?= new Busyverse.Presenter()

  setup: ->
    console.log(Busyverse.banner)
    @canvas = document.getElementById('busyverse')
    if @canvas != null
      @canvas.addEventListener 'mousedown', @handleClick
      (new Busyverse.Views.SplashView(null, @canvas.getContext('2d'))).render()
    else
      console.log "--- warning: canvas is null" if Busyverse.debug

    @game.setup()

    @ui.attach(@canvas)

    $('#terminal').submit @handleCommand

    people = @game.world.city.population
    options = $('#target')
    options.append $('<option />').val(-1).text('all')
    $.each people, -> options.append $('<option />').val(@id).text(@name)

    document.onkeypress = (e) => @handleKeypress(e)
     
  run: -> @game.play(@ui)

  handleClick: (event) => @game.click(@ui.renderer.projectedMousePos, event)

  handleKeypress: (event) ->
    if event.keyCode == 61 # +
      if Busyverse.scale <= 1.1
        Busyverse.scale = Busyverse.scale * 1.45
        @ui.attach(@canvas)
        @ui.centerAt(@ui.offsetPos)
      else
        console.log "already zoomed in as far as we will permit"
    else if event.keyCode == 45 # -
      if Busyverse.scale >= 0.15
        Busyverse.scale = Busyverse.scale * 0.6
        @ui.attach(@canvas)
        @ui.centerAt(@ui.offsetPos)
      else
        console.log "already zoomed out as far as we will permit"

    else if event.keyCode == 32 # space
      @ui.centerAt(@game.world.city.center())

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
