#= require busyverse
#= require player

context "Player", ->
  describe ".score", ->
    beforeEach ->
      @player = new Busyverse.Player()
  
    it 'should start at zero', ->
      expect(@player.score).to.equal(0)


