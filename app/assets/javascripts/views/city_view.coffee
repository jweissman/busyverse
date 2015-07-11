#= require views/view
class Busyverse.Views.CityView extends Busyverse.View
  personViews: {}

  renderPeople: =>
    console.log "render city pop" if Busyverse.verbose
    city = @model

    for person in city.population
      @personViews[person] ?= new Busyverse.Views.PersonView(person, @context)
      person_view = @personViews[person]
      person_view.render()

    @context.fillStyle = "white"
    @context.font = "bold 20px Helvetica"
    @context.fillText "#{city.name} (#{city.buildings.length} buildings)", 570, 500


