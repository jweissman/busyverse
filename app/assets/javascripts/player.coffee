class Busyverse.Player
  constructor: ->
    @score = 0
    @random = new Busyverse.Support.Randomness()
    @color = { red: 240, blue: 240, green: 240 }

    console.log "new player created with score #{@score}!" if Busyverse.debug


