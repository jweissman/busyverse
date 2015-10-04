#= require busyverse
#= require building

context 'Building', ->
  beforeEach ->
    @farm = new Busyverse.Building([2,3], size: [2,3])

  describe "#doesOverlap", ->
    it 'should indicate whether a position overlaps', ->
      expect(@farm.doesOverlap([2,2], [2,2])).to.eql(true)
      expect(@farm.doesOverlap([5,5], [2,2])).to.eql(false)
