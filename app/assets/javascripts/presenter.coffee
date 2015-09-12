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
      @offset = { x: 0, y: 0 }
      @renderer = new Busyverse.IsoRenderer(@canvas)
    else
      console.log "WARNING: canvas is null in Presenter#attach" if Busyverse.debug

  centerAt: (pos, scale=Busyverse.scale) =>
    console.log "---> Presenter#centerAt"
    console.log "  => pos: #{pos}"
    target = @renderer.iso._translatePoint(Isomer.Point(pos[0]*scale, pos[1]*scale))
    console.log "  => target: "
    console.log target
    # console.log "pos"
    # console.log pos
    w = @canvas.width
    h = @canvas.height
    # console.log "canvas width/height"
    # console.log w
    # console.log h

    # cx = @offset.x - (pos.x - w/4) 
    # cy = @offset.y - (pos.y - h/4) 

    cx = target.x + w/4
    cy = target.y + h/4

    r = 255
    g = 0
    b = 0
    a = 100
    @context.fillStyle = "rgba("+r+","+g+","+b+","+(a/255)+")";
    # @context.fillRect( cx, cy, 10, 10 );
    #@context.fillRect( target.x, target.y, 10, 10 ); # => yes! :)

    center = { x: w/2, y: h/2 }
    @context.fillRect( center.x, center.y, 10, 10 ); # => yes! :)

    @translate(w/2 - target.x, h/2 - target.y)

    # what we want is center 

    # @translate target.x, target.y

  translate: (x,y) =>
    console.log "New offset! => #{x}, #{y}"
    @offset = {x: x, y: y} 

  render: (world) =>
    console.log "Rendering!" if Busyverse.debug

    @clear()
    @context.save()
    # @context.scale(1.5,1.5)
    @context.translate(@offset.x,@offset.y)
    @renderer.draw world
    @context.restore()

    # really just renders the ui at this point
    # maybe move person tags *into* this layer
    @renderCity(world.city, world)

  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  renderCity: (city, world) ->
    console.log "----> Rendering city" if Busyverse.verbose
    (new Busyverse.Views.CityView(city, @context)).render(world)
