Color = Isomer.Color
Shape = Isomer.Shape
Pyramid = Shape.Pyramid
Prism = Shape.Prism
Point = Isomer.Point

class Tree
  size: [ 1, 1, 2.5 ]
  constructor: (xy) ->
    @x = xy[0]
    @y = xy[1]

class Busyverse.IsoView
  scale: Busyverse.scale
  constructor: (@world) ->
    @red  = new Color(160, 60, 50)
    @blue = new Color(50, 60, 160)
    @green = new Color(60, 150, 50)
    @white = new Color(160, 160, 160)

    @geometry = new Busyverse.Support.Geometry()

    @models = @assembleModels() # world

  assembleModels: (mousePosition) =>
    models = []

    for resource in @world.resources
      if @world.isLocationExplored resource.position
        shape = @constructResourceShape resource
        models.push {shape: shape, color: @green, size: [1,1]}

    for building in @world.city.buildings
      shape = @constructBuildingShape building
      models.push {shape: shape, color: @red, size: building.size}

    for person in @world.city.population
      shape = @constructPersonShape person
      models.push {shape: shape, color: @white, size: [1,1]}

    if mousePosition
      building = new Busyverse.Buildings.Farm(mousePosition)
      cursor = @constructBuildingShape building
      color = @white
      if @world.tryToBuild(building, false)
        color = @red
      models.push({shape: cursor, color: color, size: building.size})

    models.sort(@isCloserThan) #.reverse()

  isCloserThan: (model_a,model_b) =>
    @camera = [-10,-10,30]
    a = model_a.shape.paths[0].points[0]
    b = model_b.shape.paths[0].points[0]

    a_pos = [a.x + model_a.size[0]/2, a.y + model_a.size[1]/2, 0]
    b_pos = [b.x + model_a.size[0]/2, b.y + model_b.size[1]/2, 0]

    delta_a = @geometry.euclideanDistance(a_pos, @camera)
    delta_b = @geometry.euclideanDistance(b_pos, @camera)

    less_than_condition = delta_a < delta_b
    more_than_condition = delta_a > delta_b

    return 1  if less_than_condition
    return -1 if more_than_condition
    return 0

  constructResourceShape: (resource) =>
    tree = new Tree(resource.position)
    @pyramid(tree.x, tree.y, tree.size)

  constructBuildingShape: (building) =>
    @prism(building.position[0], building.position[1], building.size[0], building.size[1], building.size[2])

  constructPersonShape: (person) =>
    x = person.position[0] / Busyverse.cellSize
    y = person.position[1] / Busyverse.cellSize
    @prism(x,y, 0.3,0.3,1.2)

  assembleCellModel: (cell) =>
    cell_shape = @prism(cell.location[0], cell.location[1], 1,1,0.01) 
    color = @blue
    if cell.color == 'darkgreen'
      color = @green
    else if cell.color == 'red'
      color = @red
    { shape: cell_shape, color: color }

  point: (x,y,z=0) -> Point(x * @scale, y * @scale, z * @scale)

  prism: (x,y,length,width,height) ->
    Prism( @point(x,y), length * @scale, width * @scale, height * @scale)

  pyramid: (x,y,size) -> 
    location = @point(x, y)
    length = size[0] * @scale
    width = size[1] * @scale
    height = size[2] * @scale
    return Pyramid( location, length, width, height )
