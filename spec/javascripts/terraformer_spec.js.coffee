#= require busyverse
#= require support/randomness
#= require terraformer
#= require spec_helper

describe 'Terraformer', ->
  describe '.compose', ->
    describe 'when composing a map', ->
      it 'should respect the evolve parameter', ->
        terraformer = new Busyverse.Terraformer()
        map = { eachCell: -> }
        distribution = {}
        sinon.spy terraformer, "evolve"
        terraformer.compose(map, distribution, false)
        terraformer.evolve.should.not.have.been.called

