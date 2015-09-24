#= require isomer
#= require support/geometry
#= require iso_renderer
#= require iso_view

class Busyverse.BoundingBox
  constructor: (@name, @position, @size) ->
  hit: (pos) ->
    console.log "new bounding box #{@name} at"
    console.log @position
    console.log "of size"
    console.log @size
    console.log "--- was hit at ...?"
    console.log pos
    wasHit = @position[0] <= pos.x <= @position[0] + @size[0] &&
             @position[1] <= pos.y <= @position[1] + @size[1]
    console.log wasHit
    return wasHit


class Busyverse.Presenter
  constructor: () ->
    @views = {}
    @renderer = null
    console.log 'New presenter created!' if Busyverse.debug

  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose

    if canvas != null
      @canvas   = canvas
      @context  = @canvas.getContext('2d')
      @offset   = { x: 0, y: 0 }
      @renderer = new Busyverse.IsoRenderer(@canvas)
    else
      if Busyverse.debug
        console.log "WARNING: canvas is null in Presenter#attach"

  centerAt: (pos, scale=Busyverse.scale) =>
    return false if @renderer == null
    point = Isomer.Point(pos[0]*scale, pos[1]*scale)
    target = @renderer.iso._translatePoint(point)
    
    w = @canvas.width
    h = @canvas.height
    @translate(w/2 - target.x, h/2 - target.y)

  translate: (x,y) =>
    console.log "New offset! => #{x}, #{y}" if Busyverse.debug
    @offset = {x: x, y: y}

  render: (world) =>
    return false if @renderer == null

    console.log "Rendering!" if Busyverse.debug
    @clear()
    @context.save()
    @context.translate(@offset.x,@offset.y)
    @renderer.draw world
    @context.restore()
    @ui_view = new Busyverse.Views.UIView(world.city, @context)
    @ui_view.render(world)

  clear: ->
    return false if @renderer == null
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  boundingBoxes: (world) ->
    boxes = []
    for element in @ui_view.constructPalette(world.city)
      box = new Busyverse.BoundingBox(element.name, element.position, element.size)
      boxes.push(box) if element.clickable
    boxes
