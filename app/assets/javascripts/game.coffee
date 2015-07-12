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
  width: 80
  height: 60
  stepLength: 30

  constructor: (@world, @player) ->
    @world  ?= new Busyverse.World(@width, @height)
    @player ?= new Busyverse.Player()
    @setup()
    console.log "New game created for world #{@world.name}!" if Busyverse.debug

  setup: =>
    farm = new Busyverse.Buildings.Farm(@world.center())
    @place(farm) 

    for i in [1..4]
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
  engine = Busyverse.engine = new Busyverse.Engine()
  window.onload = -> engine.run()
