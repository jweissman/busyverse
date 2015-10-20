#= require jquery
#= require canvasInput

class Busyverse.Engine
  constructor: (@game, @ui) ->
    @game ?= new Busyverse.Game()
    @ui   ?= new Busyverse.Presenter()

  renderBanner: -> console.log(Busyverse.banner)

  setup: ->
    console.log "Engine#setup" if Busyverse.trace
    @renderBanner()
    @canvas = document.getElementById('busyverse')
    if @canvas?
      @canvas.addEventListener 'mousedown', @handleClick
      document.onkeypress = (e) => @handleKeypress(e)
      @ui.attach(@canvas)
    @game.play(@ui)

  handleClick: (event) =>
    console.log "Engine#handleClick" if Busyverse.trace
    projectedPosition = @ui.renderer.projectedMousePos
    console.log "projectedPosition = #{projectedPosition}" if Busyverse.debug
    @game.click projectedPosition, event

  handleKeypress: (event) => @game.press(event.keyCode)

  @instrument: ->
    console.log "Engine.instrument" if Busyverse.trace
    engine = new Busyverse.Engine()
    window.onload = -> engine.setup()
    engine
