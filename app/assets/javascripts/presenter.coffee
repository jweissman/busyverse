#= require isomer
#= require support/geometry
#= require iso_renderer
#= require iso_view
#= require bounding_box

class Busyverse.Presenter
  constructor: () ->
    @views = {}
    @renderer = null
    @offset   = { x: 0, y: 0 }

    console.log 'New presenter created!' if Busyverse.debug

  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose


    if canvas != null
      @canvas   = canvas
      @context  = @canvas.getContext('2d')

      @bgCanvas = document.createElement('canvas')
      @bgCanvas.width  = 15000
      @bgCanvas.height = 15000
      
      @fgCanvas = document.createElement('canvas')
      @fgCanvas.width  = 15000
      @fgCanvas.height = 15000
      @renderer = new Busyverse.IsoRenderer(@canvas, @bgCanvas, @fgCanvas)

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

  translate: (x, y) =>
    if Busyverse.trace
      console.log "Presenter@translate #{x}, #{y}"

    @offset = {x: x, y: y}

  render: (world) =>
    return false if @renderer == null

    console.log "Rendering!" if Busyverse.debug
    @clear()
    @context.save()
    @context.translate(@offset.x,@offset.y)
    @renderer.drawBg(world, @offset)
    @renderer.draw(world, @offset)
    @context.restore()
    @ui_view = new Busyverse.Views.UIView(world.city, @context)
    @ui_view.render(world)

  clear: ->
    return false if @renderer == null
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  boundingBoxes: (world) ->
    boxes = []
    for element in @ui_view.constructPalette(world.city)
      {name, position, size} = element
      box = new Busyverse.BoundingBox(name, position, size)
      boxes.push(box) if element.clickable
    boxes
