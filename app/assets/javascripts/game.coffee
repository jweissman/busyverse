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

  stepLength: 50
  initialPopulation: 1

  constructor: (@world, @player) ->
    @world  ?= new Busyverse.World(@width, @height, @cellSize)
    @player ?= new Busyverse.Player()
    @setup()
    console.log "Game#new world=#{@world.name}" if Busyverse.debug

  setup: =>
    console.log "Game#setup"
    origin = #@world.center() 
      # @world.mapToCanvasCoordinates(
      @world.randomPassableAreaOfSize(2)
    console.log "Using origin #{origin}"
    farm = new Busyverse.Buildings.Farm(origin)
    @place(farm) 

    for i in [1..@initialPopulation]
      @world.city.grow(@world)

  play: (ui) =>
    console.log 'Playing!'
    @launch(ui)
    true

  send: (command) =>
    person = @world.city.population[0]
    console.log "Sending command #{command} to citizen #{person.name}..." if Busyverse.debug
    person.send(command, @world.city, @world)

  launch: (ui) =>
    console.log 'Launching!' if Busyverse.verbose
    @ui = ui
    @step()

  step: =>
    console.log "tick" if Busyverse.debug and Busyverse.verbose
    @update()
    @render()
    setTimeout @step, @stepLength

  place: (building) => 
    console.log "Game#place [building=#{building.name}] at #{building.position}"
    @world.city.create(building)

  update: () => @world.update() 

  render: () =>
    console.log "Rendering to UI" if Busyverse.verbose
    @ui.render(@world)

# kickstart fn
Busyverse.kickstart = ->
  #Busyverse.game = new Busyverse.Game() 
  engine = Busyverse.engine = new Busyverse.Engine( Busyverse.game)
  window.onload = -> engine.run()
