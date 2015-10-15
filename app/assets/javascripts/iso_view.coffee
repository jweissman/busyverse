Color   = Isomer.Color
Shape   = Isomer.Shape
Pyramid = Shape.Pyramid
Prism   = Shape.Prism
Point   = Isomer.Point

class Busyverse.IsoView
  camera: [-40,-40,40]
  geometry: new Busyverse.Support.Geometry()

  red: new Color(160, 60, 50, 0.125)
  blue: new Color(50, 60, 160)
  green: new Color(60, 150, 50)
  white: new Color(160, 160, 160, 0.125)

  constructor: (@world) ->
    @scale = Busyverse.scale

  constructStableModels: =>
    for building in @world.city.buildings
      @constructBuildingModel building

  constructDynamicModels: (mousePosition) =>
    dynamicModels = []

    for resource in @world.resources
      if @world.isAnyPartOfAreaExplored resource.position, resource.size
        shape = @constructResourceShape resource
        { position, size } = resource
        { red, green, blue } = resource.color
        color = new Color(red, green, blue)
        dynamicModels.push { color, shape, position, size }

    for person in @world.city.population
      shape = @constructPersonShape person
      { red, green, blue } = person.color
      color = new Color(red, green, blue)
      position = [
        (person.position[0] / Busyverse.cellSize),
        (person.position[1] / Busyverse.cellSize),
        0
      ]
      size = person.size

      dynamicModels.push { shape, color, position, size }

    if mousePosition && Busyverse.engine.game.chosenBuilding
      name = Busyverse.engine.game.chosenBuilding.name
      pos = [mousePosition[0], mousePosition[1], 0]
      building = Busyverse.Building.generate(name, pos)

      color = @red
      if @world.tryToBuild(building, false)
        { red, green, blue } = building.color
        color = new Color(red, green, blue, 0.2)
        shouldStack = @world.city.shouldNewBuildingBeStacked(
          building.position, building.size, building.name)
        if shouldStack
          building.position[2] = building.size[2] *
                                 @world.city.stackHeight(building.position)

      model = @constructBuildingModel(building, color)
      dynamicModels.push(model)
    dynamicModels

  assembleModels: (mousePosition) =>
    models = []

    for model in @constructStableModels()
      models.push model

    for model in @constructDynamicModels(mousePosition)
      models.push model

    models.sort @isCloserToCamera

  computeModelDepth: (model, size=true) ->
    factor = 10000000
    depth = Math.floor((model.position[0])*factor) +
            Math.floor((model.position[1])*factor) -
            (0.01 * (model.position[2]||0))
    if size
      depth += Math.floor((model.size[0]/2) * factor) +
               Math.floor((model.size[1]/2) * factor) +
               0.01 * model.size[2]
    depth

  isCloserToCamera: (model_a,model_b) =>
    a = @computeModelDepth(model_a)
    b = @computeModelDepth(model_b)
    if a < b
      1
    else if b < a
      -1
    else
      0

  constructBuildingModel: (building, color) =>
    { red, green, blue } = building.color
    color ?= new Color(red, green, blue)
    x = building.position[0]
    y = building.position[1]
    z = building.position[2]
    h = building.size[2]
    shape = @constructBuildingShape building, x, y, z, h
    {
      shape: shape
      color: color
      position: [x, y, z]
      size: building.size
    }

  constructResourceShape: (resource) =>
    { size, age, name, position } = resource
    x = position[0]
    y = position[1]
    if age < 10 && name == 'wood'
      size = [
        size[0] * ((age+5)/15),
        size[1] * ((age+5)/15),
        size[2] * ((age+5)/15)
      ]
      x += 0.5 - size[0]/2
      y += 0.5 - size[1]/2

    pyramid = @pyramid(x, y, size)
    pyramid

  constructBuildingShape: (building, x, y, z, h) =>
    w = building.size[0]
    l = building.size[1]
    h ?= building.size[2]
    @prism(x, y, z, w, l, h)

  constructPersonShape: (person) =>
    x = person.position[0] / Busyverse.cellSize
    y = person.position[1] / Busyverse.cellSize
    @prism(x,y,0.0, person.size[0],person.size[1],person.size[2])

  assembleCellModel: (cell) =>
    x = cell.location[0]
    y = cell.location[1]
    cell_shape = @prism(x, y, 0, 0.95,0.95,0.01)
    color = @blue
    if cell.color == 'darkgreen'
      color = @green
    else if cell.color == 'red'
      color = @red
    { shape: cell_shape, color: color }

  point: (x,y,z=0) -> Point(x * @scale, y * @scale, z * @scale)

  prism: (x,y,z,length,width,height) ->
    Prism( @point(x,y,z), length * @scale, width * @scale, height * @scale)

  pyramid: (x,y,size) ->
    location = @point(x, y)
    length = size[0] * @scale
    width = size[1] * @scale
    height = size[2] * @scale
    return Pyramid( location, length, width, height )
