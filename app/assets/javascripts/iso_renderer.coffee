Point = Isomer.Point

class Busyverse.IsoRenderer
  constructor: (@canvasElement, @backgroundCanvas, @foregroundCanvas) ->
    @context  = @canvasElement.getContext '2d'
    @offscreenContext = @backgroundCanvas.getContext '2d'
    @foregroundContext = @foregroundCanvas.getContext '2d'

    offset = 5000
    @iso    = new Isomer(@canvasElement, originX: offset, originY: offset)
    @bg_iso = new Isomer(@backgroundCanvas, originX: offset, originY: offset)
    @fg_iso = new Isomer(@foregroundCanvas, originX: offset, originY: offset)

    @projectedMousePos = null
    @canvasElement.addEventListener 'mousemove', ((evt) =>
      @mousePos = @getMousePos(@canvasElement, evt)
      @projectedMousePos = @projectCoordinate([@mousePos.x, @mousePos.y])
      return
    ), false

  getMousePos: (canvas, evt) ->
    rect = canvas.getBoundingClientRect()
    {
      x: evt.clientX - (rect.left)
      y: evt.clientY - (rect.top)
    }

  constructView: (world) -> new Busyverse.IsoView(world)

  constructCellModels: (view, world) ->
    for location in world.city.getNewlyExploredLocations()
      cell = world.map.getCellAt location
      cell_model = view.assembleCellModel cell

  drawCells: (cell_models, offset) =>
    for cell_model in cell_models
      @bg_iso.add cell_model.shape, cell_model.color

    { x, y } = offset
    { width, height } = @canvasElement
    src = @offscreenContext.canvas

    w = Math.floor width
    h = Math.floor height
    x = Math.floor x
    y = Math.floor y

    @context.drawImage src, -x, -y, w, h, -x, -y, w, h

  drawModels: (view, world, offset) =>
    { width, height } = @canvasElement
    { x, y } = offset

    w = Math.floor width
    h = Math.floor height
    x = Math.floor x
    y = Math.floor y

    @foregroundContext.clearRect -x, -y, w, h

    for model in view.assembleModels(@projectedMousePos)
      @fg_iso.add(model.shape, model.color)

    src = @foregroundContext.canvas

    @context.drawImage src, -x, -y, w, h, -x, -y, w, h

  drawPeopleLabels: (world) =>
    scale = Busyverse.scale
    @context.fillStyle = "#FFFFFF"
    @context.font = "Bold 30px Helvetica"

    for person in world.city.population
      x = person.position[0]*scale / Busyverse.cellSize
      y = person.position[1]*scale / Busyverse.cellSize
      point = Point(x, y)
      pos = @iso._translatePoint(point)
      personView = new Busyverse.Views.PersonView(person, @context)
      personView.render(pos.x, pos.y)

  drawBg: (world, offset) =>
    view = @constructView(world)
    cell_models = @constructCellModels(view,world)

    @drawCells(cell_models, offset)

  draw: (world, offset) =>
    view = @constructView(world)
    @drawModels(view, world, offset)
    @drawPeopleLabels(world)

  projectCoordinate: (xy) =>
    scale  = Busyverse.scale
    offset = Busyverse.engine.game.ui.offset
    x = (xy[0] * 2) - offset.x
    y = (xy[1] * 2) - offset.y
    tx = @iso.transformation
    ox = @iso.originX
    oy = @iso.originY

    if Busyverse.debug
      console.log "project #{xy} with tx #{tx} by origin #{ox},#{oy}"

    det = (tx[0][1] * tx[1][0]) - (tx[0][0] * tx[1][1])

    a = (ox * tx[1][1])
    px =   (a  + (oy * tx[1][0]) - (tx[1][0] * y) - (tx[1][1] * x)) / det

    d = (-(ox * tx[0][1]))
    py = (d - (ox * tx[0][0]) + (tx[0][0] * y) + (tx[0][1] * x)) / det

    # offsetX = -0.0 / scale
    # offsetY = 0.0 / scale

    x = Math.floor(px/scale) # + offsetX)
    y = Math.floor(py/scale) # + offsetY)
    [ x, y ]
