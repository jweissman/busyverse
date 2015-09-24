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

