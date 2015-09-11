#= require busyverse
#= require grid

context "Grid", ->
  beforeEach ->
    @grid = new Busyverse.Grid(10, 10)  

  describe ".width", ->
    it 'should be 10', ->
      expect(@grid.width).to.equal(10)

  describe ".height", ->
    it 'should be 10', ->
      expect(@grid.height).to.equal(10)
