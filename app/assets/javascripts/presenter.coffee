#= require isomer
#= require support/geometry
#= require iso_renderer
#= require iso_view

class Busyverse.Presenter
  constructor: () ->
    @views = {}
    console.log 'New presenter created!' if Busyverse.debug

  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose

    if canvas != null
      @canvas   = canvas
      @context  = @canvas.getContext('2d')
      @renderer = new Busyverse.IsoRenderer(@canvas)
    else
      console.log "WARNING: canvas is null in Presenter#attach" if Busyverse.debug

  render: (world) =>
    console.log "Rendering!" if Busyverse.debug

    @clear()
    @renderer.draw world

    # really just renders the ui at this point
    # maybe move person tags *into* this layer
    @renderCity(world.city, world)

  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  renderCity: (city, world) ->
    console.log "----> Rendering city" if Busyverse.verbose
    (new Busyverse.Views.CityView(city, @context)).render(world)
