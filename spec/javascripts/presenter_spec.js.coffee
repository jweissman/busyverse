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
    @drawImage = sinon.spy()

    @context  =
      beginPath: ->
      rect: @rect
      clearRect: ->
      fill: ->
      fillText: @fillText
      stroke: ->
      save: ->
      canvas: -> { width: 0, height: 0 }
      translate: ->
      restore: ->
      drawImage: -> @drawImage
      measureText: -> { width: 0 }

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
      describeDate: -> "today"
    }

    @presenter = new Busyverse.Presenter()
    @presenter.attach @canvas

    @drawBg = sinon.spy @presenter.renderer, 'drawBg'

  describe '#attach', ->
    it 'should capture the current canvas context', ->
      expect(@presenter.canvas).to.eql(@canvas)

  describe "#render", ->
    it 'should render the world', ->
      @presenter.render @world, false
      @drawBg.should.have.been.called.once
