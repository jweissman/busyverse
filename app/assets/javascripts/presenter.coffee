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
    @offsetPos = [0,0]

  cachedCanvases: {}
  getCanvas: (name) =>
    if !@cachedCanvases[name]
      canvas = document.createElement('canvas')
      @cachedCanvases[name] = canvas
      return canvas
    @cachedCanvases[name]


  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose

    if canvas != null
      @canvas   = canvas
      @context  = @canvas.getContext('2d')

      sz = Busyverse.bufferSize
      @bgCanvas = @getCanvas("background")
      @bgCanvas.width  = sz
      @bgCanvas.height = sz
      
      @fgCanvas = @getCanvas("foreground")
      @fgCanvas.width  = sz
      @fgCanvas.height = sz

      @renderer = new Busyverse.IsoRenderer(@canvas, @bgCanvas, @fgCanvas)

    else
      if Busyverse.debug
        console.log "WARNING: canvas is null in Presenter#attach"

  centerAt: (pos, scale=Busyverse.scale) =>
    return false if @renderer == null
    @offsetPos = pos
    point = Isomer.Point(pos[0]*scale, pos[1]*scale)
    target = @renderer.fg_iso._translatePoint(point)
    
    w = @canvas.width
    h = @canvas.height
    @translate(w/2 - target.x, h/2 - target.y)

  translate: (x, y) =>
    if Busyverse.trace
      console.log "Presenter@translate #{x}, #{y}"

    @offset = {x: x, y: y}

  # zoom: (direction) => if direction == 'in' then ... else ...

  render: (world) =>
    return false if @renderer == null

    console.log "Rendering!" if Busyverse.debug
    @clear()
    @renderer.drawBg(world, @offset)
    @renderer.draw(world, @offset)
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
