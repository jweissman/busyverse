class Busyverse.Person
  size: [10,10]
  activeTask: "idle"

  constructor: (@name, @position) ->
    @position ?= [0,0]
    console.log "new person (#{@name}) created at #{@position}"

  send: (cmd) => @activeTask = cmd


