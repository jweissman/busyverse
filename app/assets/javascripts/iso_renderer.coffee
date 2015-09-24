Point = Isomer.Point

class Busyverse.IsoRenderer
  constructor: (@canvasElement) ->
    @context  = @canvasElement.getContext('2d')
    #console.log @iso
    @iso = new Isomer(@canvasElement) #@canvas)

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

  draw: (world, scale=Busyverse.scale) =>
    view = new Busyverse.IsoView(world)

    world.map.eachCell (cell) =>
      if world.isCellExplored(cell)
        cell_model = view.assembleCellModel(cell)
        @iso.add cell_model.shape, cell_model.color

    for model in view.assembleModels(@projectedMousePos)
      @iso.add(model.shape, model.color)
    
    @context.fillStyle = "#FFFFFF"
    @context.font = "Bold 30px Helvetica"

    for person in world.city.population
      x = person.position[0]*scale / Busyverse.cellSize
      y = person.position[1]*scale / Busyverse.cellSize
      point = Point(x, y)
      pos = @iso._translatePoint(point)
      view = new Busyverse.Views.PersonView(person, @context)
      view.render(pos.x, pos.y)

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

    offsetX = -0.0 / scale
    offsetY = 3.0 / scale

    x = Math.floor(px/scale + offsetX)
    y = Math.floor(py/scale + offsetY)
    [ x, y ]
