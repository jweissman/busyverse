class Busyverse.Engine
  constructor: (@game) ->
    @game ?= new Busyverse.Game()
    @ui   = new Busyverse.Presenter()

  run: ->
    @canvas = document.getElementById('busyverse')

    if typeof(jQuery) == 'undefined'
      console.log "--- warning: jQuery is undefined!" if Busyverse.debug
    else
      $('#terminal').submit @handleCommand
    
    # Turn the lights on
    @ui.attach(@canvas)

    # @background_worker = Busyverse.createWorker()
    # @background_worker.onmessage = (result) =>
    #   @handleWorkerResult result.data
    
    # Kick game engine
    console.log "Playing game!" if Busyverse.debug
    @game.play(@ui)

  # handleWorkerResult: (result) =>
  #   console.log "GOT WORKER RESULT"
  #   @game.send #result
  #     type: 'worker_result'
  #     data: result

  handleCommand: (event) =>
    command = $("input:first").val()

    result = @game.send command

    console.log "Sent command #{command} to game with result #{result}" if Busyverse.debug
    $("span#response").text(result)

    event.preventDefault()
    return


