class Busyverse.Presenter
  views: []
  constructor: () ->
    console.log 'New presenter created!' if Busyverse.debug

  attach: (canvas) =>
    console.log "About to create drawing context" if Busyverse.verbose
    @canvas   = canvas
    @context  = @canvas.getContext('2d')

  render: (game) =>
    console.log "Rendering!" if Busyverse.verbose
    @clear()
    @renderBuildings(game) && @renderPeople(game)

  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  renderBuildings: (game) =>
    @city_view ?= new Busyverse.CityView(game.city, @context)
    @city_view.renderBuildings()

  renderPeople: (game) =>
    @city_view ?= new Busyverse.CityView(game.city, @context)
    @city_view.renderPeople()

# todo move view objects out

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

