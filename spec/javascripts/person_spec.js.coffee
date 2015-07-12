#= require busyverse
#= require person

context "Person", ->
  beforeEach ->
    @person = new Busyverse.Person("Alice")

  describe ".name", ->
    it 'should be "Alice"', ->
      expect(@person.name).to.equal("Alice")

  describe ".position", ->
    it 'should be [0,0]', ->
      expect(@person.position).to.deep.equal([0,0])

  describe ".activeTask", ->
    it 'should be "idle"', ->
      expect(@person.activeTask).to.equal("idle")

  describe "#send", ->
    it 'should adopt a new active task', ->
      @person.send("wander")
      expect(@person.activeTask).to.equal("wander")
      # @person.send("build")
      # expect(@person.activeTask).to.equal("build")

  describe "#wander", ->
    it 'should advance towards a randomly selected destination', ->
      somewhere = [10,10]
      world = { 
        nearestUnexploredCell: => somewhere
        canvasToMapCoordinates: (xy) => xy
        mapToCanvasCoordinates: (xy) => xy
        anyUnexplored: -> true
        randomLocation: -> somewhere
      }
      city = center: -> 
      @person.wander(world, city)
      expect(@person.destination).to.equal(somewhere)

  describe "#move", ->
    it 'should advance position by velocity', ->
      world = {
        markExplored: (pos) ->
        markExploredSurrounding: (pos) ->
        canvasToMapCoordinates: (pos) ->
      }
      @person.velocity = [1,1]
      @person.move(world)
      expect(@person.position).to.deep.equal([1, 1])


