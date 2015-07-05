class Busyverse.World
  width: 200
  height: 200
  constructor: ->
    console.log("Created new #{@width}x#{@height} world!") if Busyverse.debug

  randomLocation: ->
    console.log("Finding random location")
    location = [Math.floor(Math.random() * @width), Math.floor(Math.random() * @height)]
    console.log "Using random location #{location}"
    location
