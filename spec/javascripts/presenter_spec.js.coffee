#= require busyverse
#= require views/view
#= require views/world_view
#= require views/city_view
#= require views/building_view
#= require views/person_view
#= require game
#= require presenter
#= require sinon

context "Presenter", ->
  beforeEach ->
    @game = new Busyverse.Game()
    @presenter = new Busyverse.Presenter() #@game)

  describe "#attach", ->
    it 'should get the canvas context', ->
      canvas_api = getContext: ->
      canvas_mock = sinon.mock(canvas_api)
      canvas_mock.expects("getContext").once()

      @presenter.attach(canvas_api)

      canvas_mock.verify()

  describe "#render", ->
    beforeEach ->
      @context_api = 
        fillRect: ->
        fillText: ->
      @context_mock = sinon.mock(@context_api)
      @canvas_api = getContext: => @context_api
      @canvas_mock = sinon.mock(@canvas_api)
      @presenter.attach(@canvas_api)

    afterEach -> @context_mock.verify()

    it 'should draw the world', ->
      # zero size world (i.e., 1x1) for testing cell rendering
      @game.world = new Busyverse.World(0,0) 
      @game.world.cellSize = 2
      @context_mock.expects("fillRect").withArgs(0,0,1,1)
      @presenter.renderWorld(@game.world)
      expect(@context_api.fillStyle).to.equal('black')

    it 'should draw buildings', ->
      example_building = new Busyverse.Buildings.Farm()
      center = @game.world.center()
      scale  = @game.world.cellSize

      @context_mock.expects("fillRect").once().withArgs(
        center[0] * scale, center[1] * scale, 
        (example_building.size[0] * scale) - 1,
        (example_building.size[1] * scale) - 1
      )

      @presenter.renderBuildings(@game)
      expect(@context_api.fillStyle).to.equal(example_building.color)

    it 'should draw people', ->
      @context_mock.expects("fillRect").once().withArgs(400,300,10,10)
      @context_mock.expects("fillText").thrice()
      @presenter.renderPeople(@game)
      expect(@context_api.fillStyle).to.equal('white')
      expect(@context_api.font).to.eql("bold 20px Helvetica")
