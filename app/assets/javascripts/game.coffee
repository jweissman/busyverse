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

  send: (command) =>
    console.log "Game#send command=#{command}"
    console.log command
    op = command
    person = @world.city.detectIdleOrWanderingPerson() # population[0]
    if person
      console.log "Sending command #{op} to citizen #{person.name}..." if Busyverse.debug
      person.send(op)
    else
      console.log "NO IDLE CIVILIAN AVAILABLE, SENDING TO #{firstCivilian}"
      firstCivilian = @world.city.population[0]
      firstCivilian.send(op)
    
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

# kickstart fn
Busyverse.kickstart = ->
  engine = Busyverse.engine = new Busyverse.Engine(Busyverse.game)
  engine.setup()
  window.onload = -> engine.run()
