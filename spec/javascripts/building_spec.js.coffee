#= require busyverse
#= require buildings/building
#= require buildings/farm
#= require buildings/house
#= require buildings/tower

context 'Building', ->
  beforeEach ->
    @farm  = new Busyverse.Buildings.Farm([2,3])
    @house = new Busyverse.Buildings.House([5,4])
    @tower = new Busyverse.Buildings.Tower([4,5])

  describe '.color', ->
    it 'should be grey for towers', ->
      expect(@tower.color).to.eql({ red: 60, green: 60, blue: 60})

  describe "#doesOverlap", ->
    it 'should indicate whether a position overlaps', ->
      expect(@farm.doesOverlap([2,2], [2,2])).to.eql(true)
      expect(@farm.doesOverlap([4,4], [2,2])).to.eql(false)
      # expect(@farm.doesOverlap([3,4], [2,2])).to.eql(false)
