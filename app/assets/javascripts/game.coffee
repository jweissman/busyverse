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
  stepLength: 30
  constructor: (@city, @player, @world) ->
    console.log 'New game created!' if Busyverse.verbose
    @city   ?= new Busyverse.City()
    @player ?= new Busyverse.Player()
    @world  ?= new Busyverse.World()
    @setup()

  setup: =>
    origin = [0,0]
    farm = new Busyverse.Buildings.Farm(origin)
    @place(farm) 
    @city.grow()

  play: (ui) =>
    console.log 'Playing!'
    @launch(ui)
    true

  send: (command) =>
    person = @city.population[0]
    console.log "Sending command #{command} to citizen #{person.name}..." if Busyverse.debug
    person.send(command)

  launch: (ui) =>
    console.log 'Launching!' if Busyverse.verbose
    @ui = ui
    @step()

  step: =>
    console.log "tick" if Busyverse.debug and Busyverse.verbose
    @update()
    @render()
    setTimeout @step, @stepLength

  place: (building) ->
    @city.create(building)

  update: () =>
    @city.update(@world)

  render: () =>
    console.log "Rendering to UI" if Busyverse.verbose
    @ui.render(@)

# kickstart
engine = Busyverse.engine = new Busyverse.Engine()
window.onload = -> engine.run()
