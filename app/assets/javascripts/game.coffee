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

  stepLength: 25

  constructor: (@world, @player) ->
    @player ?= new Busyverse.Player()
    @world  ?= new Busyverse.World(@width, @height, @cellSize)

  setup: ->
    @world.setup()
    console.log "Game#new world=#{@world.name}" if Busyverse.debug

  play: (ui) ->
    console.log 'Playing!'
    @launch(ui)
    true

  send: (command) =>
    console.log "Game#send command=#{command}"
    console.log command
    op = command
    person = @world.city.population[0]
    console.log "Sending command #{op} to citizen #{person.name}..." if Busyverse.debug
    person.send(op)
    
  launch: (ui) =>
    console.log 'Launching!' if Busyverse.verbose
    @ui = ui
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

# kickstart fn
Busyverse.kickstart = ->
  engine = Busyverse.engine = new Busyverse.Engine(Busyverse.game)
  engine.setup()
  window.onload = -> engine.run()
