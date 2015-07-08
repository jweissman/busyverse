#= require busyverse
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
      expect(@context_api.fillStyle).to.equal('green')

    it 'should draw buildings', ->
      @context_mock.expects("fillRect").once().withArgs(0,0,20,25)
      @presenter.renderBuildings(@game)
      expect(@context_api.fillStyle).to.equal('rgb(255,128,0)')

    it 'should draw people', ->
      @context_mock.expects("fillRect").once().withArgs(0,0,10,10)
      @context_mock.expects("fillText").twice()
      @presenter.renderPeople(@game)
      expect(@context_api.fillStyle).to.equal('blue')
      expect(@context_api.font).to.eql("bold 16px Arial")
