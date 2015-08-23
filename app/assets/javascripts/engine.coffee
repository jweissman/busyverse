class Busyverse.Engine
  constructor: (@game) ->
    @game ?= new Busyverse.Game()
    @ui   = new Busyverse.Presenter()

  setup: -> @game.setup()

  run: ->
    @canvas = document.getElementById('busyverse')
    # @canvas.addEventListener 'mousedown', ((evt) =>

    # ), false

    if typeof(jQuery) == 'undefined'
      console.log "--- warning: jQuery is undefined!" if Busyverse.debug
    else
      $('#terminal').submit @handleCommand
    
    # Turn the lights on
    @ui.attach(@canvas)

    @canvas.addEventListener 'mousedown', @handleClick
    
    # Kick game engine
    console.log "Playing game!" if Busyverse.debug
    @game.play(@ui)

  handleClick: (event) =>
    console.log "Handling click event!"
    # scalingFactor = Busyverse.cellSize / Busyverse.scale
    mouseLocation = @ui.renderer.projectedMousePos
    # [ 
    #   Math.floor(@ui.renderer.projectedMousePos[0]), # / scalingFactor), 
    #   Math.floor(@ui.renderer.projectedMousePos[1]) # / scalingFactor) 
    # ]
    @game.placeBuilding(mouseLocation) #@ui.renderer.mousePos)

  handleCommand: (event) =>
    command = $("input:first").val()

    result = @game.send command

    console.log "Sent command #{command} to game with result #{result}" if Busyverse.debug
    $("span#response").text(result)

    event.preventDefault()
    return


