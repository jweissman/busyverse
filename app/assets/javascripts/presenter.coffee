class Busyverse.Presenter
  views: []
  constructor: (@game) ->
    console.log 'New presenter created!'

  attach: (canvas) =>
    console.log "About to create drawing context"
    @context = canvas.getContext('2d')

  render: =>
    console.log "Rendering!"
    @renderBuildings() && @renderPeople()

  renderBuildings: =>
    @city_view ?= new Busyverse.CityView(@game.city, @context)
    @city_view.renderBuildings()

  renderPeople: =>
    @city_view ?= new Busyverse.CityView(@game.city, @context)
    @city_view.renderPeople()


# todo move view objects out

class Busyverse.BuildingView
  constructor: (@building, @context) ->
    console.log "New building view created!"

  render: =>
    console.log "rendering building at #{@building.position} of size #{@building.size}"
    console.log "---> #{@building.position[0]}, #{@building.position[1]} -- #{@building.size[0]}, #{@building.size[1]}"
    @context.fillStyle='rgb(255,128,0)'
    # @context.fillRect(0,0,20,25)
    @context.fillRect(
      parseInt( @building.position[0] ),
      parseInt( @building.position[1] ),
      parseInt( @building.size[0]     ),
      parseInt( @building.size[1]     ) 
    )

class Busyverse.PersonView
  constructor: (@person, @context) ->
    console.log "New person view created!"

  render: =>
    console.log "rendering person at #{@person.position}"
    @context.fillStyle='rgb(128,255,128)'
    @context.fillRect(
      parseInt( @person.position[0] ),
      parseInt( @person.position[1] ),
      parseInt( @person.size[0]     ),
      parseInt( @person.size[1]     ) 
    )

class Busyverse.CityView
  buildingViews: {}
  personViews: {}

  constructor: (@city, @context) ->
    console.log "New city view created!"

  renderBuildings: =>
    console.log "render city buildings"
    for building in @city.buildings
      @buildingViews[building] ?= new Busyverse.BuildingView(building, @context)
      building_view = @buildingViews[building]
      building_view.render()

  renderPeople: =>
    console.log "render city pop"
    for person in @city.population
      @personViews[person] ?= new Busyverse.PersonView(person, @context)
      person_view = @personViews[person]
      person_view.render()

