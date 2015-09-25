#= require busyverse

class Busyverse.BoundingBox
  constructor: (@name, @position, @size) ->
  hit: (pos) ->
    if Busyverse.trace
      console.log "new bounding box #{@name} at"
      console.log @position
      console.log "of size"
      console.log @size
      console.log "--- was hit at ...?"
      console.log pos
    wasHit = @position[0] <= pos.x <= @position[0] + @size[0] &&
             @position[1] <= pos.y <= @position[1] + @size[1]
    console.log wasHit if Busyverse.debug
    return wasHit



