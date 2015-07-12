#= require busyverse
#= require views/view
#= require views/world_view
#= require views/city_view
#= require views/building_view
#= require views/person_view
#= require game
#= require presenter
#= require spec_helper

context "Presenter", ->
  describe "#attach", ->
    it 'should get the canvas context', ->
      presenter = new Busyverse.Presenter()

      canvas_api = getContext: ->
      canvas_mock = sinon.mock(canvas_api)
      canvas_mock.expects("getContext").once()

      presenter.attach(canvas_api)

      canvas_mock.verify()

  describe "#render", ->
    beforeEach ->
      @fillRect = sinon.spy()
      @context  = fillRect: @fillRect
      @canvas   = getContext: => @context

      @world = new Busyverse.World(0,0) 
      @presenter = new Busyverse.Presenter()
      @presenter.attach @canvas
      
    it 'should draw the world as it is being explored', ->
      @world.markExplored([0,0])
      
      @presenter.renderWorld @world

      sz = @world.cellSize - 1
      expect(@fillRect).to.have.been.calledWith(0,0,sz,sz)

      cell = @world.map.getCellAt([0,0])
      console.log cell
      color = cell.color
      console.log color
      expect(@context.fillStyle).to.eql(color)

    it 'should draw buildings', ->
      farm = new Busyverse.Buildings.Farm([0,0])
      @world.city.create(farm)
      @presenter.renderBuildings(@world)
      sz = @world.mapToCanvasCoordinates(farm.size) # * world.cellSize
      expect(@fillRect).to.have.been.calledWith(0,0,sz[0]-1,sz[1]-1)

    # it 'should draw people', ->
    #   person = new Busyverse.Person()

    # it 'should draw buildings', ->
    #   farm = new Busyverse.Buildings.Farm([0,0])
    #   world = new Busyverse.World()
    #   world.city.create(farm)
    #   console.log "Created new world for spec"

    #   console.log world
    #   scale  = world.cellSize

    #   @context_mock.expects("fillRect").once().withArgs(
    #     0, 0,
    #     (farm.size[0] * scale) - 1,
    #     (farm.size[1] * scale) - 1
    #   )

    #   presenter = new Busyverse.Presenter()
    #   presenter.attach(@canvas_api)
    #   presenter.renderBuildings(world)

    #   expect(farm.color).to.eql('darkgreen')
    #   expect(@context_api.fillStyle).to.equal(farm.color)

    # it 'should draw people', ->
    #   world = new Busyverse.World()
    #   @context_mock.expects("fillRect").once().withArgs(400,300,10,10)
    #   @context_mock.expects("fillText").thrice()
    #   
    #   presenter = new Busyverse.Presenter()
    #   presenter.attach(@canvas_api)
    #   presenter.renderPeople(world)

    #   expect(@context_api.fillStyle).to.equal('white')
    #   expect(@context_api.font).to.eql("bold 20px Helvetica")
