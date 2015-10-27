class Busyverse.PathFoundEventHandler
  constructor: (@agent) ->
  handle: (event) =>
    console.log "PathFoundEventHandler#handle"
    console.log event

    { path } = event.data
    @agent.path = path
    @agent.recomputing = false


