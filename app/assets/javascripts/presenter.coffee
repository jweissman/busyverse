class Busyverse.Presenter
  views: []
  constructor: () ->
    console.log 'New presenter created!' if Busyverse.debug

  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose
    if canvas != null
      @canvas   = canvas
      @context  = @canvas.getContext('2d')
    else
      console.log "WARNING: canvas is null in Presenter#attach" if Busyverse.debug

  render: (game) =>
    console.log "Rendering!" if Busyverse.verbose
    if typeof(@canvas) != 'undefined'
      @clear()
      @renderWorld(game.world)
      @renderBuildings(game) 
      @renderPeople(game)
    else
      console.log "WARNING: @canvas is undefined in Presenter#render" if Busyverse.debug and Busyverse.verbose

  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  renderWorld: (world) =>
    @worldView ?= new Busyverse.Views.WorldView(world, @context)
    @worldView.render()

  renderBuildings: (game) =>
    console.log "rendering #{@city.buildings.length} city buildings" if Busyverse.debug and Busyverse.verbose
    for building in game.city.buildings
      (new Busyverse.Views.BuildingView(building, @context)).render(game.world)

  renderPeople: (game) =>
    @city_view ?= new Busyverse.Views.CityView(game.city, @context)
    @city_view.renderPeople()

