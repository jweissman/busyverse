#= require sinon
#= require busyverse
#= require city
#= require game

describe "Player.score", ->
  beforeEach ->
    @player = new Busyverse.Player()

  it 'should start at zero', ->
    expect(@player.score).to.equal(0)

context "City", ->
  beforeEach ->
    @city = new Busyverse.City()

  describe "#create", ->
    it 'should create structures', ->
      origin = [0,0]
      farm = new Busyverse.Buildings.Farm(origin)
      @city.create(farm)
      expect(@city.buildings).to.include(farm)

  describe "#grow", ->
    beforeEach ->
      @city = new Busyverse.City()
  
    it 'should increase population', ->
      old_population = @city.population
      @city.grow()
      new_population = @city.population
      new_population.should.equal(old_population+1)


describe "Game", ->
  beforeEach ->
    @player = new Busyverse.Player()
    @city = new Busyverse.City()
    @game = new Busyverse.Game(@city, @player)

  describe '.player', ->
    it 'should have the expected player', ->
      @game.player.should.equal(@player)

  describe '.city', ->
    it 'should have  city', ->
      @game.city.should.equal(@city)

  describe "#setup", ->
    beforeEach ->
      @game = new Busyverse.Game()
      @game.setup()
  
    it 'should place a farm at the origin', ->
      firstStructure = @game.city.buildings[0]
      expect(firstStructure.name).to.equal("Small Farm")
      expect(firstStructure.position).to.deep.equal([0,0])

  describe "#place", ->
    beforeEach ->
      @game = new Busyverse.Game()
      @game.setup()

    it 'should create structures', ->
      tower = new Busyverse.Buildings.Tower([5,5])
      @game.place(tower)
      expect(@game.city.buildings).to.include(tower)

context "Presenter", ->
  beforeEach ->
    @game = new Busyverse.Game()
    @presenter = new Busyverse.Presenter(@game)

  describe "#attach", ->
    it 'should get the canvas context', ->
      canvas_api = getContext: ->
      canvas_mock = sinon.mock(canvas_api)
      canvas_mock.expects("getContext").once()

      @presenter.attach(canvas_api)

      canvas_mock.verify()

  describe "#render", ->
    beforeEach ->
      @context_api = fillRect: ->
      @context_mock = sinon.mock(@context_api)
      @canvas_api = getContext: => @context_api
      @canvas_mock = sinon.mock(@canvas_api)
      @presenter.attach(@canvas_api)

    afterEach -> @context_mock.verify()

    it 'should draw buildings', ->
      @context_mock.expects("fillRect").once().withArgs(0,0,2,2)
      @presenter.render()
      expect(@context_api.fillStyle).to.equal('rgba(128,128,128,128)')
