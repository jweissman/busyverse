Point = Isomer.Point

class Busyverse.IsoRenderer
  constructor: (
    @canvasElement, @backgroundCanvas, @foregroundCanvas, @overlayCanvas) ->

    @newlyCreated = true
    @lastInfluencedCells = []

    @context           = @canvasElement.getContext '2d'
    @offscreenContext  = @backgroundCanvas.getContext '2d'
    @foregroundContext = @foregroundCanvas.getContext '2d'
    @overlayContext    = @overlayCanvas.getContext '2d'

    sz = Busyverse.bufferSize
    @origin = { originX: sz * 0.50, originY: sz * 0.90 }

    @bg_iso = new Isomer(@backgroundCanvas, @origin)
    @overlay_iso = new Isomer(@overlayCanvas, @origin)
    @fg_iso = new Isomer(@foregroundCanvas, @origin)

    @projectedMousePos = null
    @canvasElement.addEventListener 'mousemove', ((evt) =>
      @mousePos = @getMousePos(@canvasElement, evt)
      @projectedMousePos = @projectCoordinate([@mousePos.x, @mousePos.y])
      return
    ), false

  reset: =>
    @newlyCreated = true
    @lastInfluencedCells = []

  getMousePos: (canvas, evt) ->
    rect = canvas.getBoundingClientRect()
    {
      x: evt.clientX - (rect.left)
      y: evt.clientY - (rect.top)
    }

  constructView: (world) -> new Busyverse.IsoView(world)

  constructCellModels: (view, world) ->
    locations = world.city.getNewlyExploredLocations()

    if @newlyCreated
      locations = world.city.allExploredLocations()
      @newlyCreated = false

    for location in locations
      cell = world.map.getCellAt location
      view.assembleCellModel cell

  drawCells: (
    cell_models, offset, iso=@bg_iso, ctx=@offscreenContext, clear=false) =>

    { x, y } = offset
    { width, height } = @canvasElement
    src = ctx.canvas

    w = Math.floor width
    h = Math.floor height
    x = Math.floor x
    y = Math.floor y

    ctx.clearRect(0,0,Busyverse.bufferSize,Busyverse.bufferSize) if clear

    for cell_model in cell_models
      iso.add cell_model.shape, cell_model.color

    @context.drawImage src, -x, -y, w, h, 0, 0, w, h

  constructBackgroundOverlayModels: (view, world) ->
    return [] unless world.city.influencedCells
    world.city.recomputeInfluence() if world.city.influencedCells.length == 0
    cells = world.city.influencedCells.slice()
    return [] if cells.length == @lastInfluencedCells.length

    @lastInfluencedCells = cells

    color = Busyverse.engine.game.player.color
    cell_color = new Isomer.Color(color.red, color.green, color.blue, 0.1125)
    perimeter_color = new Isomer.Color(color.red, color.green, color.blue, 0.25)

    for cell in cells
      cell_model = view.assembleCellModel cell
      cell_model.color = if world.city.onPerimeter(cell)
        perimeter_color
      else
        cell_color
      cell_model

  drawModels: (view, world, offset, clear=true) =>
    { width, height } = @canvasElement
    { x, y } = offset

    w = Math.floor width
    h = Math.floor height
    x = Math.floor x
    y = Math.floor y

    @foregroundContext.clearRect(-x, -y, w, h ) if clear
    models = view.assembleModels(@projectedMousePos)

    for model in models
      @fg_iso.add(model.shape, model.color)

    @drawPeopleLabels(world)

    src = @foregroundContext.canvas

    @context.drawImage src, -x, -y, w, h, 0, 0, w, h

  drawPeopleLabels: (world) =>
    scale = Busyverse.scale
    for person in world.city.population
      x = person.position[0]*scale / Busyverse.cellSize
      y = person.position[1]*scale / Busyverse.cellSize
      point = Point(x, y)
      pos = @fg_iso._translatePoint(point)
      personView = new Busyverse.Views.PersonView(person, @foregroundContext)
      personView.render(pos.x, pos.y)

  drawBg: (world, offset) =>
    view = @constructView(world)

    cell_models = @constructCellModels(view,world)
    @drawCells(cell_models, offset)

    overlay_models = @constructBackgroundOverlayModels(view,world)
    clear = overlay_models.length != 0
    @drawCells(overlay_models, offset, @overlay_iso, @overlayContext,clear)

  draw: (world, offset) =>
    view = @constructView(world)
    @drawModels(view, world, offset)

  projectCoordinate: (xy) =>
    return [0,0] unless Busyverse.engine.game.ui

    scale  = Busyverse.scale
    offset = Busyverse.engine.game.ui.offset

    x = (xy[0] * 2) - (offset.x)
    y = (xy[1] * 2) - (offset.y)

    tx = @bg_iso.transformation

    { originX, originY } = @bg_iso

    ox = originX
    oy = originY

    det = (tx[0][1] * tx[1][0]) - (tx[0][0] * tx[1][1])

    a = (ox * tx[1][1])
    px =   (a  + (oy * tx[1][0]) - (tx[1][0] * y) - (tx[1][1] * x)) / det

    d = (-(ox * tx[0][1]))
    py = (d - (oy * tx[0][0]) + (tx[0][0] * y) + (tx[0][1] * x)) / det

    offsetPos = Busyverse.engine.game.ui.offsetPos
    x = Math.floor(px/scale)
    y = Math.floor(py/scale)

    [ x, y ]
