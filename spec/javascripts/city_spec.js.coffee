#= require city
#= require buildings/farm

context "City", ->
  beforeEach ->
    @city = new Busyverse.City()

    origin = [0,0]
    @farm = new Busyverse.Buildings.Farm(origin)

  describe "#create", ->
    it 'should create structures', ->
      @city.create(@farm)
      expect(@city.buildings.length).to.eql(1)
      expect(@city.buildings).to.include(@farm)

  describe "#grow", ->
    beforeEach ->
      @city = new Busyverse.City()
  
    it 'should increase population size', ->
      old_population = @city.population.length
      @city.grow(mapToCanvasCoordinates: -> )
      new_population = @city.population.length
      new_population.should.equal(old_population+1)

  describe "#availableForBuilding", ->
    it 'should indicate building locations', ->
      @city.create(@farm)
      expect(@city.availableForBuilding(@farm.position, [1,1])).to.equal(false)
      expect(@city.availableForBuilding([4,5], [2,2])).to.equal(true)
