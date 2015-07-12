class Busyverse.View
  constructor: (@model, @context) ->
    console.log "Created new view for model #{@model} in context #{@context}" if Busyverse.debug and Busyverse.verbose

  x: -> @model.position[0]
  y: -> @model.position[1]
  width: -> @model.size[0]
  height: -> @model.size[1]

  position: -> @model.position
  size: -> @model.size


  rect: (position: pos, size: size, fill: fill, stroke: stroke) =>
    x = pos[0]
    y = pos[1]
    w = size[0]
    h = size[1]
    @context.beginPath()
    @context.rect(x,y,w,h)  #x + 30, y - 15, 100, 35
    @context.fillStyle = fill #'lightblue'
    @context.fill()
    @context.lineWidth = 2
    @context.strokeStyle = stroke #'black'
    @context.stroke()




