class Busyverse.View
  constructor: (@model, @context) ->
    console.log "Created new view for model #{@model} in context #{@context}" if Busyverse.debug and Busyverse.verbose

