#= require busyverse
#= require grid
#= require world
#= require sinon

context "World", ->
  beforeEach ->
    @width = 10
    @height = 25
    @world = new Busyverse.World(@width, @height)

  describe ".width", ->
    it 'should be 20', ->
      expect(@world.width).to.eql(@width)

  describe '.height', ->
    it 'should be 30', ->
      expect(@world.height).to.eql(@height)

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
      expect(@world.canvasToMapCoordinates([25.3, 26.7])).to.deep.eql([3, 3])
