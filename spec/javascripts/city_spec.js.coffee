#= require city
#= require buildings/farm

context "City", ->
  beforeEach ->
    @city = new Busyverse.City()

  describe "#create", ->
    it 'should create structures', ->
      origin = [0,0]
      farm = new Busyverse.Buildings.Farm(origin)
      @city.create(farm)
      expect(@city.buildings).to.include(farm)

  describe "#grow", ->
    beforeEach ->
      @city = new Busyverse.City()
  
    it 'should increase population', ->
      old_population = @city.population
      @city.grow()
      new_population = @city.population
      new_population.should.equal(old_population+1)


