#= require busyverse
#= require city
#= require game

describe "Game", ->
  beforeEach ->
    @player = new Busyverse.Player()
    @city   = new Busyverse.City()
    @game   = new Busyverse.Game(@city, @player)

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
  
    it 'should place a farm at the center', ->
      firstStructure = @game.city.buildings[0]
      expect(firstStructure.name).to.equal("Small Farm")
      expect(firstStructure.position).to.eql(@game.world.center())

    it 'should create a person at the center', ->
      expect(@city.population.length).to.equal(1)
      expect(@city.population[0].position).to.eql(
        @game.world.mapToCanvasCoordinates(
          @game.world.center()
        )
      )

  describe "#place", ->
    beforeEach ->
      @game = new Busyverse.Game()
      @game.setup()

    it 'should create structures', ->
      tower = new Busyverse.Buildings.Tower([5,5])
      @game.place(tower)
      expect(@game.city.buildings).to.include(tower)
