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
    stroke ?= 'black'
    x = pos[0]
    y = pos[1]
    w = size[0]
    h = size[1]

    @context.beginPath()
    @context.rect(x,y,w,h)
    @context.fillStyle = fill
    @context.fill()
    @context.lineWidth = 1
    @context.strokeStyle = stroke
    @context.stroke()

  text: (msg: msg, position: pos, size: size, font: font, fill: fill, style: style) =>
    font ?= "Helvetica"
    fill ?= 'black'
    size ?= '16px'
    style ?= ''

    @context.fillStyle = fill
    @context.font = "#{style} #{size} #{font}"

    @context.fillText msg, pos[0], pos[1]

  textWidth: (msg: msg, font: font, size: size, style: style) =>
    font ?= "Helvetica"
    size ?= '16px'
    style ?= ''

    @context.font = "#{style} #{size} #{font}"
    @context.measureText(msg).width
