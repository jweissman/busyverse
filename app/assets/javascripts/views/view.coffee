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

  text: (opts, write=true) =>
    { msg, position, size, font, fill, style, align, maxWidth } = opts
    font ?= "Helvetica"
    fill ?= 'black'
    size ?= '16px'
    align ?= 'left'
    style ?= ''
    maxWidth ?= 1000
    position ?= [0,0]

    console.log "View#text msg='#{msg}'" if Busyverse.trace

    @context.fillStyle = fill
    @context.font = "#{style} #{size} #{font}"
    @context.textAlign = align

    x = position[0]
    y = position[1]

    metrics = @context.measureText(msg)
    lineHeight = 40

    return unless msg

    words = msg.split(' ')
    line = ''
    n = 0
    lines = []
    while n < words.length
      testLine = line + words[n] + ' '
      metrics = @context.measureText(testLine)
      testWidth = metrics.width
      if testWidth > maxWidth and n > 0
        @context.fillText(line, x, y) if write
        lines.push line
        line = words[n] + ' '
        y += lineHeight
      else
        line = testLine
      n++
    @context.fillText(line, x, y) if write
    lines.push line
    lines


  textWidth: (opts) =>
    { msg, font, size, style } = opts
    font ?= "Helvetica"
    size ?= '16px'
    style ?= ''

    @context.font = "#{style} #{size} #{font}"
    @context.measureText(msg).width
