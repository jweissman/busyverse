#= require_tree ./buildings
#= require city

class Busyverse.Player
  constructor: ->
    @score = 0
    console.log "new player created with score #{@score}!"

class Busyverse.Game
  constructor: (@city, @player) ->
    console.log 'New game created!'
    @city ?= new Busyverse.City()
    @player ?= new Busyverse.Player()
    @setup()

  setup: ->
    origin = [0,0]
    farm = new Busyverse.Buildings.Farm(origin)
    @place(farm) 

  play: ->
    console.log 'Playing!'
    @launch()
    true

  launch: ->
    console.log 'Launching!'

  place: (building) ->
    @city.create(building)

  update: ->
    @city.update()

class Busyverse.Renderer
  constructor: (@ctx) ->
    console.log("New drawing context created!")

  rect: (xy, wh, color) ->
    color ?= 'rgba(128,128,128,128)'
    @ctx.fillStyle = color
    @ctx.fillRect(xy[0], xy[1], wh[0], wh[1])

class Busyverse.CityView
  constructor: (@city) ->
    console.log "New city view created!"

  render: (renderer) =>
    console.log "render city"
    for building in @city.buildings
      renderer.rect(building.position, building.size, building.color)
      # ctx.fillStyle='rgb(255,128,0)'
      # ctx.fillRect(0,0,100,100)


class Busyverse.Presenter
  constructor: (@game) ->
    console.log 'New presenter created!'
    @views = []
    @views.push(new Busyverse.CityView(@game.city))

  attach: (canvas) =>
    console.log "About to create drawing context"
    console.log(canvas)
    @context = canvas.getContext('2d')
    @renderer = new Busyverse.Renderer(@context)

  render: =>
    console.log("would be running ui loop?")
    for view in @views
      view.render(@renderer)

# kickstart
class Busyverse.Engine
  constructor: ->
    @game = new Busyverse.Game()
    @ui   = new Busyverse.Presenter(Busyverse.game)

  run: ->
    @canvas = document.getElementById('busyverse')
    
    # Turn the lights on
    @ui.attach(@canvas)
    @ui.render()
    
    # Kick game engine
    @game.play()

engine = Busyverse.engine = new Busyverse.Engine()
window.onload = -> engine.run()
