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

      @offscreenCanvas = document.createElement('canvas')
      @offscreenCanvas.width  = 15000 # canvas.width  * 1.0 # + 100 # * 2
      @offscreenCanvas.height = 15000 # canvas.height * 1.0 # + 100 # * 2
      #@offscreenCanvas.getContext('2d').translate(1000, 1000)
      # Does this become easier if stop translating context around for scrolling?
      # We have to know what goes under the camera
      # And translate everything accordingl
      # Seems nightmarish really !
      # But then after that maybe simpler to do layers with
      # offscreen canvas
      # Worth it??

      @renderer = new Busyverse.IsoRenderer(@canvas, @offscreenCanvas)

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
    console.log "New offset! => #{x}, #{y}" #if Busyverse.debug
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
