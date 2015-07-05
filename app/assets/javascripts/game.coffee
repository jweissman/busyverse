#= require busyverse
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


# class Busyverse.Renderer
#   constructor: (@ctx) ->
#     console.log("New drawing context created!")
# 
#   rect: (x, y, w, h, color) =>
#     color ?= 'rgba(128,128,128,128)'
#     @ctx.fillStyle = color
#     console.log("Drawing rectangle at #{x}, #{y} of size #{w}x#{h}")
#     @ctx.fillRect(0,0,20,25) #x,y,w,h)

class Busyverse.BuildingView
  constructor: (@building, @context) ->
    console.log "New building view created!"

  render: =>
    console.log "rendering building at #{@building.position} of size #{@building.size}"
    console.log "---> #{@building.position[0]}, #{@building.position[1]} -- #{@building.size[0]}, #{@building.size[1]}"
    @context.fillStyle='rgb(255,128,0)'
    # @context.fillRect(0,0,20,25)
    @context.fillRect(
      parseInt( @building.position[0]),
      parseInt( @building.position[1]),
      parseInt( @building.size[0]    ),
      parseInt( @building.size[1]    ) 
    )
 
class Busyverse.CityView
  buildingViews: {}

  constructor: (@city, @context) ->
    console.log "New city view created!"

  render: =>
    console.log "render city"
    for building in @city.buildings
      @buildingViews[building] ?= new Busyverse.BuildingView(building, @context)
      building_view = @buildingViews[building]
      building_view.render()

class Busyverse.Presenter
  views: []
  constructor: (@game) ->
    console.log 'New presenter created!'

  attach: (canvas) =>
    console.log "About to create drawing context"
    @context = canvas.getContext('2d')

  render: =>
    console.log "Rendering!"
    city_view = new Busyverse.CityView(@game.city, @context)
    city_view.render()

# kickstart
class Busyverse.Engine
  constructor: ->
    @game = new Busyverse.Game()
    @ui   = new Busyverse.Presenter(@game) #Busyverse.game)

  run: ->
    @canvas = document.getElementById('busyverse')
    
    # Turn the lights on
    @ui.attach(@canvas)
    @ui.render()
    
    # Kick game engine
    @game.play()

engine = Busyverse.engine = new Busyverse.Engine()
window.onload = -> engine.run()
