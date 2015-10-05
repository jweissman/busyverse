#= require busyverse
#= require city
#= require game
#= require sinon

describe "Game", ->
  describe '.world', ->
    it 'should be as assigned', ->
      world = {}
      game = new Busyverse.Game(world)
      game.world.should.equal(world)

  describe '.player', ->
    it 'should have a score', ->
      world  = {}
      player = { name: 'Rucker' }
      game = new Busyverse.Game(world, player)
      game.player.should.equal(player)

  describe '.click', ->
    it 'should handle ui clicks', ->
      world = {}
      game = new Busyverse.Game(world)

      game.ui = {
        renderer: { mousePos: [5,4] },
        boundingBoxes: -> [
          { name: 'woot', hit: -> true }
        ]
      }

      evt = { shiftKey: false }

      position = [213, 432]
      sinon.spy(game, "handleClickElement")
      game.click(position, evt)
      game.handleClickElement.should.have.been.called
      game.handleClickElement.getCall(0).args[0].should.equal('woot')
