#= require isomer
#= require support/geometry
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

  assembleModels: =>
    models = []


    for resource in @world.resources
      if @world.isLocationExplored resource.position
        shape = @constructResourceShape resource
        models.push {shape: shape, color: @green}

    for building in @world.city.buildings
      shape = @constructBuildingShape building
      models.push {shape: shape, color: @red}

    for person in @world.city.population
      shape = @constructPersonShape person
      models.push {shape: shape, color: @white}

    models.sort(@isCloserThan) #.reverse()

  isCloserThan: (model_a,model_b) =>
    @camera = [-1.0,-1.0]
    a = model_a.shape.paths[0].points[0]
    b = model_b.shape.paths[0].points[0]

    a_pos = [a.x, a.y]
    b_pos = [b.x, b.y]

    delta_a = @geometry.euclideanDistance(a_pos, @camera)
    delta_b = @geometry.euclideanDistance(b_pos, @camera)

    less_than_condition = delta_a < delta_b
    more_than_condition = delta_a > delta_b

    return 1  if less_than_condition
    return -1 if more_than_condition
    return 0

  # render: =>
  #   @world.map.eachCell (cell) => 
  #     @renderCell(cell) if @world.isCellExplored(cell)
  #   @models = @assembleModels()
  #   for model in @models
  #     @iso.add(model.shape, model.color)
  #   for person in @world.city.population


  constructResourceShape: (resource) =>
    tree = new Tree(resource.position)
    @pyramid(tree.x, tree.y, tree.size)

  constructBuildingShape: (building) =>
    #console.log "--- adding #{building.name} at #{building.position} with size #{building.size}"
    @prism(building.position[0], building.position[1], building.size[0], building.size[1], building.size[2])

  constructPersonShape: (person) =>
    x = person.position[0] / Busyverse.cellSize
    y = person.position[1] / Busyverse.cellSize
    @prism(x,y, 0.3,0.3,1.2)
    #Prism(Point(x, y, 1), 1,1,10)


  assembleCellModel: (cell) =>
    cell_shape = @prism(cell.location[0], cell.location[1], 1,1,0.05) 
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


class Busyverse.IsoRenderer
  constructor: (@canvasElement) ->
    console.log "!!!! created new iso renderer!"
    console.log "canvas => "
    console.log @canvasElement
    @context  = @canvasElement.getContext('2d')
    #console.log @iso
    @iso = new Isomer(@canvasElement) #@canvas)

    @mousePos = {}
    @canvasElement.addEventListener 'mousemove', ((evt) =>
      @mousePos = @getMousePos(@canvasElement, evt)
      console.log 'Mouse position: ' + @mousePos.x + ',' + @mousePos.y
      return
    ), false

  getMousePos: (canvas, evt) ->
    rect = canvas.getBoundingClientRect()
    {
      x: evt.clientX - (rect.left)
      y: evt.clientY - (rect.top)
    }

  draw: (world) =>
    view = new Busyverse.IsoView(world)

    world.map.eachCell (cell) => 
      if world.isCellExplored(cell)
        cell_model = view.assembleCellModel(cell)
        @iso.add cell_model.shape, cell_model.color

    for model in view.assembleModels()
      @iso.add(model.shape, model.color)

    
    @context.fillStyle = "#FFFFFF"
    @context.font = "Bold 30px Helvetica" ##{style} #{size} #{font}"

    if @mousePos.x && @mousePos.y
      pos = @projectCoordinate([@mousePos.x, @mousePos.y])
      console.log "PROJECTING COORDINATE #{pos} from" # #{@mousePos}"
      console.log @mousePos
      cursor = view.prism(pos[0] , pos[1] , 1, 1, 4)
      #   [ pos[0] / Busyverse.cellSize, pos[1] / Busyverse.cellSize ]
      # } )
      
      @iso.add cursor, @red
      
      # @context.fillText "hi", 

    for person in world.city.population 
      pos = @iso._translatePoint(Point(person.position[0] / Busyverse.cellSize, person.position[1] / Busyverse.cellSize))
        #   @projectCoordinate([
        #   person.position[0] / Busyverse.cellSize,
        #   person.position[1] / Busyverse.cellSize
        #   
      # console.log "writing person name at #{pos} (projected from #{person.position})"
      @context.fillText person.name, pos.x, pos.y #[0], pos[1] # * Busyverse.cellSize, -pos[1] * Busyverse.cellSize

  projectCoordinate: (xy) =>
    x = xy[0] 
    y = xy[1] 
    tx = @iso.transformation
    ox = @iso.originX
    oy = @iso.originY

    console.log "Projecting #{xy} using transformation #{tx} and origin #{ox}, #{oy}"
    det = (tx[0][1] * tx[1][0]) - (tx[0][0] * tx[1][1])
    px =   ((ox * tx[1][1])  + (oy * tx[1][0]) - (tx[1][0] * y) - (tx[1][1] * x)) / det
    py = ((-(ox * tx[0][1])) - (ox * tx[0][0]) + (tx[0][0] * y) + (tx[0][1] * x)) / det
    offsetX = -2.0
    offsetY = 2.0
    [ px + offsetX, py + offsetY ] 

class Busyverse.Presenter
  constructor: () ->
    @views = {}
    console.log 'New presenter created!' if Busyverse.debug

  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose

    if canvas != null
      @canvas   = canvas
      @context  = @canvas.getContext('2d')
      @renderer = new Busyverse.IsoRenderer(@canvas)
    else
      console.log "WARNING: canvas is null in Presenter#attach" if Busyverse.debug

  render: (world) =>
    console.log "Rendering!" if Busyverse.debug

    @clear()
    @renderer.draw world
    @renderCity(world.city, world)
     
    # really render ui at this point
    # @renderCity(world.city, world)
    return


    if typeof(@canvas) != 'undefined'
      @clear()

      console.log 'rendering world' if Busyverse.trace
      @renderWorld(world)


      console.log 'rendering buildings' if Busyverse.verbose
      @renderBuildings(world) 

      console.log 'rendering people' if Busyverse.verbose
      @renderPeople(world)

      console.log 'rendering city' if Busyverse.trace
      @renderCity(world.city, world)
    else
      console.log "WARNING: @canvas is undefined in Presenter#render" if Busyverse.debug and Busyverse.verbose

  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  renderWorld: (world) =>
    console.log "RENDERING WORLD" if Busyverse.debug and Busyverse.verbose
    (new Busyverse.Views.WorldView(world, @context)).render(world)
    # @renderModel(model: world, world: world) # weird
    #
  renderCity: (city, world) ->
    console.log "----> Rendering city" if Busyverse.verbose
    (new Busyverse.Views.CityView(city, @context)).render(world)

  renderBuildings: (world) =>
    console.log "Presenter#renderBuildings [world={name: #{world.name}}]" if Busyverse.trace
    city = world.city
    console.log city if Busyverse.debug

    console.log "city name => #{city.name}" if Busyverse.trace
    buildings = city.buildings
    console.log buildings if Busyverse.trace

    console.log "rendering #{buildings.length} city buildings" if Busyverse.trace#  and Busyverse.verbose
    for building in buildings
      console.log "about to render building #{building.name}" if Busyverse.trace
      console.log building if Busyverse.debug

      @views[building] = new Busyverse.Views.BuildingView(building, @context)
      @renderModel(model: building, world: world) 

  renderPeople: (world) =>
    people = world.city.population
    for person in people
      personView = new Busyverse.Views.PersonView(person, @context)
      # personView = @peopleViews[person]
      personView.render(world)

      # @renderModel(model: person, world: world)

  renderModel: (model: model, world: world) ->
    # @views[model] ?= new view_class(model, @context)
    console.log "Presenter#renderModel" if Busyverse.trace
    console.log @views[model] if Busyverse.trace

    @views[model].render world


