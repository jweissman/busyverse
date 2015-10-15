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

  handleKeypress: (event) => @game.press(event.keyCode)

  @instrument: ->
    engine = new Busyverse.Engine()
    window.onload = ->
      engine.setup()
      engine.run()
    engine
