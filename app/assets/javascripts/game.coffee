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

  click: (position) => 
    @attemptToConstructBuilding(position)

  attemptToConstructBuilding: (mouseLocation) =>
    building = new Busyverse.Buildings.Farm(mouseLocation)

    passable  = @world.isAreaPassable(mouseLocation, building.size)
    available = @world.city.availableForBuilding(mouseLocation, building.size)

    if passable && available
      console.log "Available for building!"
      @world.city.create(building)
    else
      console.log "Not available for building! (passable=#{passable}, available=#{available})"

  send: (command, person_id) =>
    console.log "Game#send command=#{command}"
    console.log command
    op = command
    console.log "WARNING: NO TARGET ID person_id PROVIDED FOR COMMAND" unless person_id
    person = @world.city.population[person_id]
    person.send op

# kickstart fn
Busyverse.kickstart = ->
  engine = Busyverse.engine = new Busyverse.Engine(Busyverse.game)
  engine.setup()
  window.onload = -> engine.run()
