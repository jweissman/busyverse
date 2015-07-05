#= require busyverse
#= require_tree ./buildings
#= require person
#= require city
#= require presenter
#= require engine
#= require player

class Busyverse.Game
  constructor: (@city, @player) ->
    console.log 'New game created!'
    @city   ?= new Busyverse.City()
    @player ?= new Busyverse.Player()
    @setup()

  setup: ->
    origin = [0,0]
    farm = new Busyverse.Buildings.Farm(origin)
    @place(farm) 
    @city.grow()

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


# kickstart
engine = Busyverse.engine = new Busyverse.Engine()
window.onload = -> engine.run()
