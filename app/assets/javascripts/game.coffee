#= require busyverse
#= require building_type
#= require building
#= require tabletop
#= require person
#= require city
#= require grid
#= require world
#= require presenter
#= require engine
#= require player

class Busyverse.Game
  width:  Math.floor Busyverse.width / Busyverse.cellSize
  height: Math.floor Busyverse.height / Busyverse.cellSize
  cellSize: Busyverse.cellSize

  stepLength: Busyverse.stepLength

  constructor: (@world, @player) ->
    @player ?= new Busyverse.Player()
    @world  ?= new Busyverse.World(@width, @height, @cellSize)

    @chosenBuilding = null
    @chosenPerson = null

    @buildingTypesSetup = false

    Tabletop.init
      key: Busyverse.buildingSheetId
      callback: @setupBuildingTypes
      simpleSheet: true

  setupBuildingTypes: (buildingData) =>
    for building in buildingData
      { name, description, cost, subtype, stackable } = building
      { width, length, height, red, green, blue } = building
      size = [ parseInt(width), parseInt(length), parseFloat(height) ]
      color =
        red: parseInt(red)
        green: parseInt(green)
        blue: parseInt(blue)
      opts = { name, description, stackable, cost, size, color, subtype }
      buildingType = new Busyverse.BuildingType(opts)
    @buildingTypesSetup = true

  play: (ui) =>
    @ui = ui
    @launch()
    true
    
  launch: -> @step()

  step: =>
    @update()

    if @chosenPerson
      @ui.centerAt(@chosenPerson.position, Busyverse.scale / Busyverse.cellSize)

    @render()
    setTimeout @step, @stepLength

  update: () =>
    if @world.ready
      @world.update()
    else
      @continueSetup()

  continueSetup: =>
    if @world.composeComplete
      if @world.resourcesDistributed
        if @world.woodsDeveloped
          @world.setupBuildings()
          @world.ready = true
          Busyverse.loadingMessages.push "Boot complete!"
        else
          @world.developWoods()
          Busyverse.loadingMessages.push "Placing first building!"
      else
        @world.setupResources()
        Busyverse.loadingMessages.push "Developing woods..."
    else if @buildingTypesSetup
      @world.setup()
      Busyverse.loadingMessages.push "Distributing resources..."


  render: () => @ui.render(@world)

  zoomFactor: 1.25
  press: (keyCode) =>
    console.log(keyCode) if Busyverse.debug

    if keyCode == 61 # +
      if Busyverse.scale * @zoomFactor <= Busyverse.maxZoom
        Busyverse.scale = Busyverse.scale * @zoomFactor
        @ui.reset()
        @ui.centerAt(@ui.offsetPos)
      else
        console.log "already zoomed in as far as we will permit"

    else if keyCode == 45 # -
      if Busyverse.scale * (1/@zoomFactor) >= 0.08
        Busyverse.scale = Busyverse.scale * (1/@zoomFactor)
        @ui.reset()
        @ui.centerAt(@ui.offsetPos)
      else
        console.log "already zoomed out as far as we will permit"

    else if keyCode == 32 # space
      @ui.centerAt(@world.city.center())
      @chosenPerson = null

  click: (position, event) =>
    console.log "Game#click position=#{position}" if Busyverse.trace
    return unless @ui && @ui.renderer

    holdingShift = event.shiftKey

    action = ''
    pos = @ui.renderer.mousePos
    return unless pos

    adjusted_pos = [ pos.x * 2, pos.y * 2 ]

    ui_hit = false
    boxes = @ui.boundingBoxes(@world)
    if boxes
      for box in boxes
        hit = box.hit adjusted_pos
        if hit
          @handleClickElement(box.name)
          ui_hit = true

    unless ui_hit
      if @chosenBuilding != null
        @attemptToConstructBuilding(position)
        if !@world.city.canAfford(@chosenBuilding) || !holdingShift
          @chosenBuilding = null
      else
        if holdingShift
          @chosenPerson = null
          @ui.centerAt(position)
        for person in @world.city.population
          pos = person.mapPosition(@world)
          if Math.abs(pos[0] - position[0]) <= 1 &&
             Math.abs(pos[1] - position[1]) <= 1
            @chosenPerson = person
            return


  handleClickElement: (elementName) =>
    console.log "Game#handleClickElement: #{elementName} " if Busyverse.trace
    for building in Busyverse.BuildingType.all
      if building.name == elementName
        @chosenBuilding = building

  attemptToConstructBuilding: (mouseLocation) =>
    if Busyverse.trace
      console.log "Game#attemptToConstructBuilding #{mouseLocation}"
    pos = [ mouseLocation[0], mouseLocation[1], 0 ]
    building = Busyverse.Building.generate(@chosenBuilding.name, pos)
    { stackable, position, size, name } = building
    if Busyverse.debug
      console.log "--- attempting to construct #{name} at #{position}"
    if stackable
      console.log "--- stackable!" if Busyverse.debug
      shouldStack = @world.city.shouldNewBuildingBeStacked(position, size, name)
      if shouldStack
        console.log "--- should stack!" if Busyverse.debug
        building.position[2] = building.size[2] *
          @world.city.stackHeight(building.position)

    @world.tryToBuild(building, true)

  send: (command) =>
    if Busyverse.trace
      console.log "Game#send command=#{command} person_id=#{person_id}"
      console.log command
    op = command

    if op == 'help'
      return "Commands: #{Busyverse.commands}"

    if @chosenPerson == null
      responses = ""
      for person in @world.city.population
        responses += person.send(op) + ". "
      responses
    else if @chosenPerson
      @chosenPerson.send op
