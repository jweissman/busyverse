#= require busyverse
#= require_tree ./buildings
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

    @chosenBuilding = new Busyverse.Buildings.Farm()

  setup: ->
    @world.setup()
    console.log "Game#new world=#{@world.name}" if Busyverse.debug

  play: (ui) =>
    @ui = ui
    console.log 'Playing!'
    @launch()
    true
    
  launch: ->
    console.log 'Launching!' if Busyverse.verbose
    @ui.centerAt @world.city.buildings[0].position
    @step()

  step: =>
    console.log "tick" if Busyverse.debug and Busyverse.verbose
    @update()
    @render()
    setTimeout @step, @stepLength

  update: () => @world.update()

  render: () =>
    console.log "Rendering to UI" if Busyverse.verbose
    @ui.render(@world)

  click: (position, event) =>
    console.log "click position=#{position} event=#{event}"

    pos = @ui.renderer.mousePos
    adjusted_pos = {x: pos.x * 2, y: pos.y * 2}

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
      @ui.centerAt(position) # -> maybe only if shift-clicking?

      # @chosenBuilding = null

  handleClickElement: (elementName) =>
    console.log "!!!!!!! handle click element: #{elementName} "
    for building in Busyverse.Building.all()
      if building.name == elementName
        console.log "would be choosing #{building.name}"
        @chosenBuilding = building

  attemptToConstructBuilding: (mouseLocation) =>
    building = Busyverse.Building.generate(@chosenBuilding.name, mouseLocation)
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
      
# kickstart fn
Busyverse.kickstart = ->
  # where does this game come from? play.html.erb?
  Busyverse.engine = new Busyverse.Engine(Busyverse.game)
  engine.setup()
  window.onload = -> engine.run()
