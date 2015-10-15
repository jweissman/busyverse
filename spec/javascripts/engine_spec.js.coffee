#= require busyverse
#= require engine
#= require spec_helper

context "Engine", ->
  beforeEach ->
    @play = sinon.spy()
    world = { city: -> }
    @game = { play: @play, world: world, setup: -> }
    @ui = { attach: -> }
    @engine = new Busyverse.Engine(@game, @ui)

  describe "#setup", ->
    it 'should bootstrap game engine', ->
      @engine.setup()
      @play.should.have.been.called.once
