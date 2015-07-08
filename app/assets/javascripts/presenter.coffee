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
    @worldView ?= new Busyverse.WorldView(world, @context)
    @worldView.render()

  renderBuildings: (game) =>
    @city_view ?= new Busyverse.CityView(game.city, @context)
    @city_view.renderBuildings()

  renderPeople: (game) =>
    @city_view ?= new Busyverse.CityView(game.city, @context)
    @city_view.renderPeople()

class Busyverse.BuildingView
  constructor: (@building, @context) ->
    console.log "New building view created!" if Busyverse.debug and Busyverse.verbose

  render: =>
    if Busyverse.debug and Busyverse.verbose
      console.log "rendering building at #{@building.position} of size #{@building.size}" 
      console.log "---> #{@building.position[0]}, #{@building.position[1]} -- #{@building.size[0]}, #{@building.size[1]}"

    @context.fillStyle='rgb(255,128,0)'
    @context.fillRect(
      parseInt( @building.position[0] ),
      parseInt( @building.position[1] ),
      parseInt( @building.size[0]     ),
      parseInt( @building.size[1]     ) 
    )

class Busyverse.PersonView
  constructor: (@person, @context) ->
    console.log "New person view created!" if Busyverse.debug and Busyverse.verbose

  render: =>
    console.log "rendering person at #{@person.position}" if Busyverse.verbose
    @context.fillStyle='rgb(128,255,128)'
    @context.fillRect(
      parseInt( @person.position[0] ),
      parseInt( @person.position[1] ),
      parseInt( @person.size[0]     ),
      parseInt( @person.size[1]     ) 
    )

    # write name and current task
    console.log ("rendering name etc") if Busyverse.verbose

    @context.fillStyle = "blue"
    @context.font = "bold 16px Arial"
    @context.fillText @person.name, @person.position[0] + 10, @person.position[1] + 10
    @context.fillText @person.activeTask, @person.position[0] + 20, @person.position[1] + 40

    if typeof(@person.destination) != 'undefined' && @person.destination != null
      @context.fillStyle='rgb(128,255,255)'
      @context.fillRect(
        parseInt( @person.destination[0] ),
        parseInt( @person.destination[1] ),
        parseInt( @person.size[0]     ),
        parseInt( @person.size[1]     ) 
      )

      @context.fillStyle = "red"
      @context.font = "bold 18px Sans Serif"
      @context.fillText "#{@person.name}'s destination", @person.destination[0] + 10, @person.destination[1] + 10

class Busyverse.CityView
  buildingViews: {}
  personViews: {}

  constructor: (@city, @context) ->
    console.log "New city view created!" if Busyverse.debug

  renderBuildings: =>
    console.log "rendering #{@city.buildings.length} city buildings" if Busyverse.debug and Busyverse.verbose
    for building in @city.buildings
      # @buildingViews[building] ?= new Busyverse.BuildingView(building, @context)
      # building_view = @buildingViews[building]
      (new Busyverse.BuildingView(building, @context)).render()

  renderPeople: =>
    console.log "render city pop" if Busyverse.verbose
    for person in @city.population
      @personViews[person] ?= new Busyverse.PersonView(person, @context)
      person_view = @personViews[person]
      person_view.render()

class Busyverse.WorldView
  constructor: (@world, @context) ->
    console.log "New world view created!" if Busyverse.debug

  render: =>
    console.log "rendering world!" if Busyverse.debug and Busyverse.verbose
    @world.map.eachCell (cell) =>
      @context.fillStyle = cell.color
      console.log "rendering world cell at #{cell.location}" if Busyverse.debug and Busyverse.verbose
      @context.fillRect(@world.cellSize * cell.location[0], 
		        @world.cellSize * cell.location[1], 
	                @world.cellSize - 1, @world.cellSize - 1)

