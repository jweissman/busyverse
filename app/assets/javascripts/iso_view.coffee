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
        models.push
          shape: shape
          color: @green
          # size: [1,1]
          position: resource.position

    for building in @world.city.buildings
      { red, green, blue } = building.color
      color = new Color(red, green, blue)
      for dx in [0...building.size[0]]
        for dy in [0...building.size[1]]
          x = building.position[0] + dx
          y = building.position[1] + dy
          shape = @constructBuildingShape building, x, y
          models.push
            shape: shape
            color: color
            position: [x,y]

    for person in @world.city.population
      shape = @constructPersonShape person
      models.push
        shape: shape
        color: @white
        # size: [1,1]
        position: person.mapPosition(@world)

    if mousePosition && Busyverse.engine.game.chosenBuilding
      name = Busyverse.engine.game.chosenBuilding.name
      building = Busyverse.Building.generate(name, mousePosition)
      # cursor = @constructBuildingShape building
      color = @white
      if @world.tryToBuild(building, false)
        { red, green, blue } = building.color
        color = new Color(red, green, blue)
      for dx in [0...building.size[0]]
        for dy in [0...building.size[1]]
          x = building.position[0] + dx
          y = building.position[1] + dy
          shape = @constructBuildingShape building, x, y
          models.push
            shape: shape
            color: color
            position: [x,y]
      # models.push
      #   shape: cursor
      #   color: color
      #   size: building.size
      #   position: building.position

    models.sort(@isCloserToCamera)

  isCloserToCamera: (model_a,model_b) =>
    #console.log "--- IsoView#isCloserToCamera"
    @camera = [-10,-10] #,30]

    a = model_a.position
    b = model_b.position

    # console.log " ====="
    # console.log " ---> model a position: #{a}"
    # console.log " ---> model a size: #{model_a.size}"
    # console.log " ====="
    # console.log " ---> model b position: #{b}"
    # console.log " ---> model b size: #{model_b.size}"
    # console.log " ====="

    a_pos = a # [a[0] + model_a.size[0], a[1]] # + model_a.size[1]]
    b_pos = b # [b[0] + model_b.size[0], b[1]] # + model_b.size[1]]

    # console.log " ---> model a adjusted position: #{a_pos}"
    # console.log " ---> model b adjusted position: #{b_pos}"

    delta_a = @geometry.euclideanDistance(a_pos, @camera)
    delta_b = @geometry.euclideanDistance(b_pos, @camera)

    # console.log " ====="
    # console.log " ---> distance of a to camera: #{delta_a}"
    # console.log " ---> distance of b to camera: #{delta_b}"

    less_than_condition = delta_a < delta_b
    more_than_condition = delta_a > delta_b

    return 1  if less_than_condition
    return -1 if more_than_condition
    return 0

  constructResourceShape: (resource) =>
    tree = new Tree(resource.position)
    @pyramid(tree.x, tree.y, tree.size)

  constructBuildingShape: (building, x, y) =>
    # x = x #building.position[0]
    # y = y # building.position[1]
    w = 1 # building.size[0]
    l = 1 # building.size[1]
    h = building.size[2]
    @prism(x, y, w, l, h)

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
