#= require busyverse
#= require city
#= require game

describe "Game", ->
  beforeEach ->
    # @player = new Busyverse.Player()
    # @city   = new Busyverse.City()
    # @game   = new Busyverse.Game(@city, @player)
    # @game.setup()

  describe '.world', ->
    it 'should have a name', ->
      world = new Busyverse.World()
      game = new Busyverse.Game(world)

      game.world.should.equal(world)
      game.world.name.should.equal("Busylandia")

  describe '.player', ->
    it 'should have a score', ->
      player = new Busyverse.Player()
      game = new Busyverse.Game(null, player)

      game.player.should.equal(player)
      game.player.score.should.equal(0)

  # describe '.world.city', ->
  #   it 'should have  city', ->
  #     city = new Busyverse.City()
  #     game = new Busyverse.Game(city)
  #     game.world.city.should.equal(city)

  describe "#setup", ->
    beforeEach -> 
      @world   = new Busyverse.World()
      @game   = new Busyverse.Game(@world, @player)
      # @game.setup()

    it 'should place a farm at the center', ->
      # @game.setup()
      # expect(@world.city.population.length).to.equal(1)
      firstStructure = @game.world.city.buildings[0]
      expect(firstStructure.name).to.equal("Small Farm")
      expect(firstStructure.position).to.eql(@game.world.center())

    it 'should create some people at the center', ->
      expect(@game.world.city.population.length).to.equal(2)
      center = @world.mapToCanvasCoordinates( @world.center())
      expect(@game.world.city.population[0].position).to.eql(center)
      expect(@game.world.city.population[1].position).to.eql(center)

  describe "#place", ->
    it 'should create structures', ->
      tower = new Busyverse.Buildings.Tower([5,5])
      @game.place(tower)
      expect(@game.world.city.buildings).to.include(tower)
