class Busyverse.Presenter
  constructor: () ->
    @views = {}
    console.log 'New presenter created!' if Busyverse.debug

  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose
    if canvas != null
      @canvas   = canvas
      @context  = @canvas.getContext('2d')
    else
      console.log "WARNING: canvas is null in Presenter#attach" if Busyverse.debug

  render: (world) =>
    console.log "Rendering!" if Busyverse.debug
    if typeof(@canvas) != 'undefined'
      @clear()

      console.log 'rendering world' if Busyverse.trace
      @renderWorld(world)

      console.log 'rendering buildings' if Busyverse.verbose
      @renderBuildings(world) 

      console.log 'rendering people' if Busyverse.verbose
      @renderPeople(world)
    else
      console.log "WARNING: @canvas is undefined in Presenter#render" if Busyverse.debug and Busyverse.verbose

  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  renderWorld: (world) =>
    console.log "RENDERING WORLD" if Busyverse.debug and Busyverse.verbose
    @views[world] = new Busyverse.Views.WorldView(world, @context)
    @renderModel(model: world, world: world) # weird

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
      @views[person] = new Busyverse.Views.PersonView(person, @context)
      @renderModel(model: person, world: world)

  renderModel: (model: model, world: world) ->
    # @views[model] ?= new view_class(model, @context)
    console.log "Presenter#renderModel" if Busyverse.trace
    console.log @views[model] if Busyverse.trace

    @views[model].render world


