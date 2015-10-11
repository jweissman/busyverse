class Busyverse.View
  constructor: (@model, @context) ->
    if Busyverse.trace
      console.log "View#new model=#{@model} context=#{@context}"

  x: -> @model.position[0]
  y: -> @model.position[1]
  width: -> @model.size[0]
  height: -> @model.size[1]

  position: -> @model.position
  size: -> @model.size


  rect: (opts) =>
    { position, size, fill, stroke } = opts
    stroke ?= 'black'
    x = position[0]
    y = position[1]
    w = size[0]
    h = size[1]

    @context.beginPath()
    @context.rect(x,y,w,h)
    @context.fillStyle = fill
    @context.fill()
    @context.lineWidth = 1
    @context.strokeStyle = stroke
    @context.stroke()

  text: (opts) =>
    { msg, position, size, font, fill, style, align } = opts
    font ?= "Helvetica"
    fill ?= 'black'
    size ?= '16px'
    align ?= 'left'
    style ?= ''

    @context.fillStyle = fill
    @context.font = "#{style} #{size} #{font}"
    @context.textAlign = align


    @context.fillText msg, position[0], position[1]

  textWidth: (opts) =>
    { msg, font, size, style } = opts
    font ?= "Helvetica"
    size ?= '16px'
    style ?= ''

    @context.font = "#{style} #{size} #{font}"
    @context.measureText(msg).width
