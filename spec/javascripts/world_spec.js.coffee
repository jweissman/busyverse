#= require busyverse
#= require grid
#= require resource
#= require resources/wood
#= require world
#= require sinon
#= require spec_helper

context "World", ->
  beforeEach ->
    @width  = 5
    @height = 5

    @world = new Busyverse.World(@width, @height)

  describe ".width", ->
    it 'should be as assigned', ->
      expect(@world.width).to.eql(@width)

  describe '.height', ->
    it "should be as assigned", ->
      expect(@world.height).to.eql(@height)

  describe '#center', ->
    it 'should indicate the center of the cell matrix', ->
      expect(@world.center()).to.eql([
        @world.width / 2,
        @world.height / 2
      ])

  describe "#setup", ->
    it 'should distribute resources', ->
      @world.setup({ 100: 'darkgreen' }, false, true, false)

      expect(@world.resources.length).to.eql(@world.startingResources)


  describe "#randomCell", ->
    it 'should be within the world', ->
      @spy = sinon.spy()
      random = valueInRange: @spy

      @world.random = random
      @world.randomCell()

      @spy.should.have.been.calledWith(@height)
      @spy.should.have.been.calledWith(@width)

  describe "#canvasToMapCoordinates", ->
    it 'should convert according to cell size', ->
      x = 25.5
      y = 54.5

      expectX = Math.round(x / @world.cellSize)
      expectY = Math.round(y / @world.cellSize)
      
      expectedLocation = [ expectX, expectY ]
      actualLocation = @world.canvasToMapCoordinates([x, y])

      expect(actualLocation).to.deep.eql(expectedLocation)

  describe "#findOpenAreasOfSizeInCity", ->
    it 'should find open areas', ->
      @world.setup({ 100: 'darkgreen' }, false, false, false)

      city =
        availableForBuilding: -> true
        center: -> [3,3]

      open_regions = @world.findOpenAreasOfSizeInCity(city, [1,1], 3)
      
      expect(open_regions.length).to.equal(27)

  describe "#getPath", ->
    it 'should find shortest path', ->
      @world.setup({ 100: 'darkgreen' }, false, false, false)

      path = @world.getPath([0,2],[3,5])
      expect(path[0]).to.eql([0,2])
      expect(path[3]).to.eql([3,5])
