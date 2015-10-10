#= require busyverse
#= require player
#= require support/randomness

context "Player", ->
  describe ".score", ->
    beforeEach ->
      @player = new Busyverse.Player()
  
    it 'should start at zero', ->
      expect(@player.score).to.equal(0)


