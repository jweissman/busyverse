#= require busyverse
#= require views/view
#= require views/ui_view
#= require views/person_view
#= require game
#= require presenter
#= require spec_helper

context "Presenter", ->
  beforeEach ->
    Busyverse.engine = { game: { chosenBuilding: {name: "Small Farm"}}}
    @rect = sinon.spy()
    @fillText = sinon.spy()

    @context  =
      beginPath: ->
      rect: @rect
      clearRect: ->
      fill: ->
      fillText: @fillText
      stroke: ->
      save: ->
      translate: ->
      restore: ->
      drawImage: ->

    @canvas    =
      getContext: => @context
      addEventListener: ->

    @world     = {
      resources: [],
      city:
        buildings: [],
        population: [],
        canAfford: -> true,
        getNewlyExploredLocations: -> [],
        allExploredLocations: -> []
      map: { eachCell: -> },
      isDay: -> false,
      describeTime: -> "midnight"
    }

    @presenter = new Busyverse.Presenter()
    @presenter.attach @canvas

  describe '#attach', ->
    it 'should capture the current canvas context', ->
      expect(@presenter.canvas).to.eql(@canvas)

  describe "#render", ->
    it 'should render the world', ->
      @presenter.render @world
      @fillText.should.have.been.called.twice
