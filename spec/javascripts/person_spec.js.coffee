#= require busyverse
#= require person

context "Person", ->
  beforeEach ->
    @person = new Busyverse.Person(1, "Alice", [0,0])

  describe '.id', ->
    it 'should be 1', ->
      expect(@person.id).to.equal(1)

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
      world = {}
      @person.send('wander', world)
      expect(@person.activeTask).to.equal("wander")

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
