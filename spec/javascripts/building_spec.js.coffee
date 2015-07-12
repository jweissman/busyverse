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
    it 'should be brown for farms', ->
      expect(@farm.color).to.eql('brown')

    it 'should be darkred for houses', ->
      expect(@house.color).to.eql('darkred')

    it 'should be grey for towers', ->
      expect(@tower.color).to.eql('grey')

  describe "#doesOverlap", ->
    it 'should indicate whether a position overlaps', ->
      expect(@farm.doesOverlap([2,2], [2,2])).to.eql(true)
      expect(@farm.doesOverlap([4,4], [2,2])).to.eql(false)
      # expect(@farm.doesOverlap([3,4], [2,2])).to.eql(false)
