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

      buildingType = new Busyverse.BuildingType
        name: name
        description: description
        stackable: stackable
        cost: cost
        size:  size
        color:  color
        subtype: subtype
        
    @world.setupBuildings()

  setup: -> @world.setup()

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

  update: () => @world.update()

  render: () => @ui.render(@world)

  press: (keyCode) =>
    console.log(keyCode) if Busyverse.debug

    if keyCode == 61 # +
      if Busyverse.scale * 1.45 <= Busyverse.maxZoom
        Busyverse.scale = Busyverse.scale * 1.45
        @ui.reset()
        @ui.centerAt(@ui.offsetPos)
      else
        console.log "already zoomed in as far as we will permit"

    else if keyCode == 45 # -
      if Busyverse.scale * 0.6 >= 0.08
        Busyverse.scale = Busyverse.scale * 0.6
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
    for box in @ui.boundingBoxes(@world)
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
