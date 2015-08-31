Point = Isomer.Point

class Busyverse.IsoRenderer
  constructor: (@canvasElement) ->
    @context  = @canvasElement.getContext('2d')
    #console.log @iso
    @iso = new Isomer(@canvasElement) #@canvas)

    @projectedMousePos = null
    @canvasElement.addEventListener 'mousemove', ((evt) =>
      @mousePos = @getMousePos(@canvasElement, evt)
      console.log('Mouse position: ' + @mousePos.x + ',' + @mousePos.y) if Busyverse.debug
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
        #models.push cell_model


    if @mousePos && @mousePos.x && @mousePos.y
      @projectedMousePos = @projectCoordinate([@mousePos.x, @mousePos.y])

      # farm = new Busyverse.Buildings.Farm(pos)
      # cursor = view.constructBuildingShape(farm)
      # @iso.add cursor, view.red
    for model in view.assembleModels(@projectedMousePos) #@mousePos)
      @iso.add(model.shape, model.color)
    
    @context.fillStyle = "#FFFFFF"
    @context.font = "Bold 30px Helvetica"

    for person in world.city.population 
      pos = @iso._translatePoint(Point(person.position[0]*scale / Busyverse.cellSize, person.position[1]*scale / Busyverse.cellSize))
      view = new Busyverse.Views.PersonView(person, @context)
      view.render(pos.x, pos.y)
      # @context.fillText person.name, pos.x, pos.y

  projectCoordinate: (xy, scale=Busyverse.scale) =>
    x = xy[0] 
    y = xy[1] 
    tx = @iso.transformation
    ox = @iso.originX
    oy = @iso.originY

    console.log "Projecting #{xy} using transformation #{tx} and origin #{ox}, #{oy}" if Busyverse.debug
    det = (tx[0][1] * tx[1][0]) - (tx[0][0] * tx[1][1])
    px =   ((ox * tx[1][1])  + (oy * tx[1][0]) - (tx[1][0] * y) - (tx[1][1] * x)) / det
    py = ((-(ox * tx[0][1])) - (ox * tx[0][0]) + (tx[0][0] * y) + (tx[0][1] * x)) / det
    offsetX = -0.0 / scale
    offsetY = 4.0 / scale
    [ Math.floor(px/scale + offsetX), Math.floor(py/scale + offsetY) ] 


