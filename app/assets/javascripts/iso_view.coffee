Color   = Isomer.Color
Shape   = Isomer.Shape
Pyramid = Shape.Pyramid
Prism   = Shape.Prism
Point   = Isomer.Point

class Tree
  size: [ 1,1,2.8 ]
  constructor: (xy) ->
    @x = xy[0]
    @y = xy[1]

class Busyverse.IsoView
  camera: [-100,-100,100]
  geometry: new Busyverse.Support.Geometry()

  red: new Color(160, 60, 50, 0.125)
  blue: new Color(50, 60, 160)
  green: new Color(60, 150, 50)
  white: new Color(160, 160, 160, 0.125)

  constructor: (@world) ->
    @scale = Busyverse.scale

  constructStableModels: =>
    stableModels = []

    for resource in @world.resources
      if @world.isLocationExplored resource.position
        shape = @constructResourceShape resource
        stableModels.push
          shape: shape
          color: @green
          position: resource.position
          height: resource.size[2]

    for building in @world.city.buildings
      { red, green, blue } = building.color
      color = new Color(red, green, blue)
      for dx in [0...building.size[0]]
        for dy in [0...building.size[1]]
          for dz in [0...building.size[2]]
            x = building.position[0] + dx
            y = building.position[1] + dy
            z = building.position[2] + dz
            h = Math.min(1.0, building.size[2])
            shape = @constructBuildingShape building, x, y, z, h
            stableModels.push
              shape: shape
              color: color
              position: [x,y,z]

    stableModels

  constructDynamicModels: (mousePosition) =>
    dynamicModels = []

    for person in @world.city.population
      shape = @constructPersonShape person
      color = new Color(person.color.red, person.color.green, person.color.blue)
      position = person.mapPosition(@world)
      dynamicModels.push
        shape: shape
        color: color
        position: position

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

      for dx in [0...building.size[0]]
        for dy in [0...building.size[1]]
          for dz in [0...building.size[2]]
            x = building.position[0] + dx
            y = building.position[1] + dy
            z = building.position[2] + dz
            h = Math.min(1.0, building.size[2])
            shape = @constructBuildingShape building, x, y, z, h
            dynamicModels.push
              shape: shape
              color: color
              position: [x,y,z]
              building_id: building.id

    dynamicModels

  assembleModels: (mousePosition) =>
    models = []

    for model in @constructStableModels()
      models.push model

    models.sort(@isCloserToCamera)

    for model in @constructDynamicModels(mousePosition)
      models.push model

    models.sort(@isCloserToCamera)

  distanceToCamera: (position) =>
    @geometry.euclideanDistance3(position, @camera)

  isCloserToCamera: (model_a,model_b) =>
    a = model_a.position
    b = model_b.position

    a_pos = [a[0], a[1], (a[2] || 0) + (model_a.height || 0)]
    b_pos = [b[0], b[1], (b[2] || 0) + (model_b.height || 0)]

    delta_a = @distanceToCamera(a_pos)
    delta_b = @distanceToCamera(b_pos)

    less_than_condition = delta_a < delta_b
    more_than_condition = delta_a > delta_b

    value = if less_than_condition
      1
    else if more_than_condition
      -1
    else
      0

    return value

  constructResourceShape: (resource) =>
    tree = new Tree(resource.position)
    @pyramid(tree.x, tree.y, tree.size)

  constructBuildingShape: (building, x, y, z, h) =>
    w = 1
    l = 1
    h ?= building.size[2]
    @prism(x, y, z, w, l, h)

  constructPersonShape: (person) =>
    x = person.position[0] / Busyverse.cellSize
    y = person.position[1] / Busyverse.cellSize
    @prism(x,y,0.0, 0.3,0.3,1.2)

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
