#= require busyverse
#= require city
#= require game

describe "Game", ->
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

  # describe #play
  # describe #launch
  # describe #send
  # describe #step
  # describe #update
  # describe #render

  # move to World#setup
  # describe "#setup", ->
  #   beforeEach -> 
  #     @world   = new Busyverse.World()
  #     @game    = new Busyverse.Game(@world, @player)

  #   it 'should place a farm at the center', ->
  #     firstStructure = @game.world.city.buildings[0]

  #     expect(firstStructure.name).to.equal("Small Farm")
  #     expect(firstStructure.position).to.eql(@game.world.center())

  #   it 'should create some people at the center', ->
  #     expect(@game.world.city.population.length).to.equal(@game.initialPopulation)

  #     center = @world.mapToCanvasCoordinates( @world.center())
  #     for i in [0..(@game.initialPopulation-1)]
  #       expect(@game.world.city.population[i].position).to.eql(center)

  # describe "#place", ->
  #   it 'should create structures', ->
  #     tower = new Busyverse.Buildings.Tower([5,5])
  #     @game.place(tower)
  #     expect(@game.world.city.buildings).to.include(tower)
