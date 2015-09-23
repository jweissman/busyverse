#= require busyverse
#= require engine
#= require spec_helper

context "Engine", ->
  beforeEach ->
    @play = sinon.spy()
    @game = { play: @play }
    @ui = { attach: -> }
    @engine = new Busyverse.Engine(@game, @ui)

  describe "#run", ->
    it 'should kick game engine', ->
      @engine.run()
      @play.should.have.been.called.once
