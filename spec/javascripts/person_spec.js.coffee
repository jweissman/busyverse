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

  describe "#wander", ->
    it 'should advance towards a randomly selected destination', ->
      somewhere = [10,10]
      world = randomLocation: => somewhere # [10,10]
      @person.wander(world)
      expect(@person.destination).to.equal(somewhere)

