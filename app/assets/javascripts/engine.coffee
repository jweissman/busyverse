#= require jquery
#= require canvasInput

class Busyverse.Engine
  constructor: (@game, @ui) ->
    @game ?= new Busyverse.Game()
    @ui   ?= new Busyverse.Presenter()

  renderBanner: -> console.log(Busyverse.banner)

  setup: ->
    @renderBanner()

    @canvas = document.getElementById('busyverse')
    if @canvas != null
      @canvas.addEventListener 'mousedown', @handleClick
      (new Busyverse.Views.SplashView(null, @canvas.getContext('2d'))).render()
    else
      console.log "--- warning: canvas is null" if Busyverse.debug

    @game.setup()
    @ui.attach(@canvas)

    $('#terminal').submit @handleCommand
    document.onkeypress = (e) => @handleKeypress(e)

    true

  onPeopleCreated: ->
    people = @game.world.city.population

    options = $('#target')
    options.empty().append $('<option />').val(-1).text('all')
    $.each people, ->
      options.append $('<option />').val(@id).text(@name)

  run: -> @game.play(@ui)

  handleClick: (event) =>
    console.log "Engine#handleClick" if Busyverse.trace
    projectedPosition = @ui.renderer.projectedMousePos
    console.log "projectedPosition = #{projectedPosition}" if Busyverse.debug
    @game.click projectedPosition, event

  handleKeypress: (event) ->
    console.log(event.keyCode) #if Busyverse.debug

    if event.keyCode == 61 # +
      if Busyverse.scale * 1.45 <= Busyverse.maxZoom
        Busyverse.scale = Busyverse.scale * 1.45
        @ui.attach(@canvas)
        @ui.centerAt(@ui.offsetPos)
      else
        console.log "already zoomed in as far as we will permit"

    else if event.keyCode == 45 # -
      if Busyverse.scale * 0.6 >= 0.08
        Busyverse.scale = Busyverse.scale * 0.6
        @ui.attach(@canvas)
        @ui.centerAt(@ui.offsetPos)
      else
        console.log "already zoomed out as far as we will permit"

    else if event.keyCode == 32 # space
      @ui.centerAt(@game.world.city.center())

    #else if event.keyCode == 96 # ~
      #@ui.toggleTerminal()

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
    window.onload = ->
      engine.setup()
      engine.run()
    engine
