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

    Tabletop.init
      key: Busyverse.buildingSheetId
      callback: @setupBuildingTypes
      simpleSheet: true

  setupBuildingTypes: (buildingData) =>
    for building in buildingData
      { name, description, cost, stackable } = building
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
        
    @world.setupBuildings()

  setup: -> @world.setup()

  play: (ui) =>
    @ui = ui
    @launch()
    true
    
  launch: -> @step()

  step: =>
    @update()
    @render()
    setTimeout @step, @stepLength

  update: () => @world.update()

  render: () => @ui.render(@world)

  click: (position) =>
    return unless @ui

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
        if @attemptToConstructBuilding(position)
          @chosenBuilding = null
      else
        @ui.centerAt(position)

  handleClickElement: (elementName) =>
    console.log "Game#handleClickElement: #{elementName} " if Busyverse.trace
    for building in Busyverse.BuildingType.all
      if building.name == elementName
        console.log "would be choosing #{building.name}" # if Busyverse.debug
        console.log building
        @chosenBuilding = building

  attemptToConstructBuilding: (mouseLocation) =>
    building = Busyverse.Building.generate(@chosenBuilding.name, mouseLocation)
    if @world.city.shouldNewBuildingBeStacked(building.position, building.size, building.name)
      building.position[2] = building.size[2] *
        @world.city.stackHeight(building.position)

    @world.tryToBuild(building, true)

  send: (command, person_id) =>
    console.log "Game#send command=#{command} person_id=#{person_id}"
    console.log command
    op = command
    unless person_id
      console.log "WARNING: NO TARGET ID person_id PROVIDED FOR COMMAND"

    if person_id < 0 # 'all'
      responses = ""
      for person in @world.city.population
        responses += person.send(op) + ". "
      responses
    else # not 'all'
      person = @world.city.population[person_id]
      person.send op
