#= require busyverse
#= require grid
#= require world
#= require sinon

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

  describe "#randomCell", ->
    it 'should be within the world', ->
      @random_api = valueInRange: (range) => 0
      @random_mock = sinon.mock(@random_api)

      @world.random = @random_api 

      @random_mock.expects("valueInRange").once().withArgs(@height)
      @random_mock.expects("valueInRange").once().withArgs(@width)

      @world.randomCell()

      @random_mock.verify()

  describe "#canvasToMapCoordinates", ->
    it 'should convert according to cell size', ->
      x = 25.5
      y = 54.5

      expectedLocation = [ Math.round(x / @world.cellSize), Math.round(y / @world.cellSize)]
      actualLocation = @world.canvasToMapCoordinates([x, y])

      expect(actualLocation).to.deep.eql(expectedLocation)

  describe "#findOpenAreaOfSizeInCity", ->
    it 'should find open areas', ->
      city = 
        availableForBuilding: -> true
        center: -> [3,3]
      open_regions = @world.findOpenAreasOfSizeInCity(city, [1,1], 4)
      expect(open_regions.length).to.equal(35)

  describe "#getPath", ->
    it 'should find shortest path', ->
      path = @world.getPath([0,2],[3,5])
      expect(path.length).to.equal(4)
      expect(path[0]).to.eql([0,2])
      expect(path[3]).to.eql([3,5])


