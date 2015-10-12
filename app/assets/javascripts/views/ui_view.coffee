#= require views/view
#= require canvasInput
#= require underscore

class Busyverse.Views.UIView extends Busyverse.View
  blank: 'whitesmoke'
  primary: 'skyblue'
  secondary: 'blanchedalmond'
  accent: 'rgba(80,0,80,0.25)'
  contrast: 'powderblue'

  render: (world, showTerm=false) =>
    city = @model

    @renderCover(world)
    @renderUi(world, city, showTerm)

  renderUi: (world, city, showTerm=false) =>
    @renderCityDetail(city)
    @renderTime(world)
    @renderResources(city)
    @renderBuildingPalette(city)
    @renderInput() if showTerm

  getInput: =>
    Busyverse.input ?= null
    return Busyverse.input if Busyverse.input != null

    w = 800
    x = @context.canvas.width / 2 - (w/2)
    y = (@context.canvas.height * 0.85) + 20
    input = new CanvasInput(
      canvas: @context.canvas
      fontSize: 50
      x: x
      extraX: -x/2
      y: y
      extraY: -y/2
      fontFamily: 'Courier New'
      fontColor: '#efefef'
      fontWeight: 100
      width: w
      height: 120
      padding: 8
      borderWidth: 1
      borderColor: '#000'
      borderRadius: 5
      boxShadow: '1px 1px 0px #202'
      backgroundGradient: ['#404', '#202']
      #backgroundColor: 'rgba(60,0,60,0.5)'
      innerShadow: '0px 0px 5px rgba(0, 0, 0, 0.5)'
      placeHolder: '>_')

    Busyverse.input = input
    Busyverse.log = [
      "","","","","","","","","","","","","",
      Busyverse.welcome,
      "Some tips:"
    ].concat(Busyverse.tips)

    Busyverse.logUpdatedAt = performance.now()
    input.onsubmit (data) ->
      console.log 'Terminal submit!' if Busyverse.trace
      cmd = Busyverse.input.value()
      Busyverse.input.value("")
      response = Busyverse.engine.game.send(cmd, -1)
      console.log response #if Busyverse.debug
      Busyverse.log.push "> #{cmd}"
      Busyverse.log.push response
      Busyverse.logUpdatedAt = performance.now()
    input

  renderInput: =>
    console.log "UiView#renderInput" if Busyverse.trace
    # should also render past output and response?
    input = @getInput()
    input.render()

    w = 800
    x = @context.canvas.width / 2 - (w/2)
    y = @context.canvas.height * 0.95

    alpha = if Busyverse.logUpdatedAt < (performance.now() - 3000)
      0.85 - (performance.now() - Busyverse.logUpdatedAt - 3000)/6000
    else
      0.85

    lines_printed = 0
    max_lines = 10

    log_lines = for evt in Busyverse.log
      opts = {
        msg: evt
        size: '32px'
        font: 'Courier New'
        maxWidth: w
      }

      @text(opts, false)

    flattened_lines =  log_lines.reduce(((a, b) ->
      a.concat(b)
    ), [])

    lines_printed = 0
    for message in flattened_lines[-10..]
      isPlayerInput = false
      if message
        if message.indexOf(">") == 0
          isPlayerInput = true

        style = 'normal'
        if isPlayerInput
          fill = "rgba(240,240,240,#{alpha})"
          style = 'bold'
        else
          fill = "rgba(160,240,160,#{alpha})"

        @text
          msg: message
          font: 'Courier New'
          position: [ x, y - 540 + (40 * lines_printed) ]
          size: '32px'
          style: style
          fill: fill #"rgba(240,240,240,#{alpha})"
          maxWidth: w
      lines_printed = lines_printed + 1

  renderCover: (world) =>
    cover = [Busyverse.width * Busyverse.cellSize,
             Busyverse.height * Busyverse.cellSize]

    if world.isDay()
      percentOfDay = world.percentOfDay()
      alpha = percentOfDay/2
      if percentOfDay >= 0.5
        alpha = 0.5 - percentOfDay/2

      @rect
        position: [0,0]
        size: cover
        fill: "rgba(128,128,0,#{alpha})"
    else
      @rect
        position: [0,0]
        size: cover
        fill: "rgba(0,0,192,0.125)"

  paletteOrigin: => [ @context.canvas.width - 380, 100 ]
  paletteElementSize: [ 300, 56 ]
  constructPalette: (city) ->
    palette = []
    building_list = Busyverse.BuildingType.all
    building_index = 0
    currentBuildingName = ''

    if Busyverse.engine.game.chosenBuilding
      currentBuildingName = Busyverse.engine.game.chosenBuilding.name

    for building in building_list

      selected = building.name == currentBuildingName
      affordable = city.canAfford building

      color = if selected
        @primary
      else
        if affordable then @contrast else @blank
  
      origin = @paletteOrigin()
      x = origin[0] + 5
      y = (origin[1] + 5 + building_index * (@paletteElementSize[1]))
      palette.push {
        name: building.name
        position: [x,y]
        size: @paletteElementSize
        fill: color
        cost: building.cost
        text: building.description
        clickable: affordable && !selected
      }

      building_index = building_index + 1
    palette

  renderBuildingPalette: (city) =>
    palette = @constructPalette(city)
    sz = [10 + @paletteElementSize[0],
          60 + palette.length * (@paletteElementSize[1]+2) ]

    origin = @paletteOrigin()
           
    @rect
      position: [origin[0] - 30, origin[1] - 80]
      size: [sz[0] + 60, sz[1] + 55]
      fill: @blank

    @text
      msg: 'Structures'
      position: [origin[0] + 5, origin[1] - 20]
      size: '36px'


    for element in palette
      @rect
        position: element.position
        size: element.size
        fill: element.fill

      @text
        msg: element.name
        position: [element.position[0] + 50, element.position[1] + 24]
        size: '24px'

      @text
        msg: element.text
        position: [element.position[0] + 50, element.position[1] + 46]
        size: '18px'

      @rect
        position: element.position
        size: [40, element.size[1]]
        fill: @accent

      @text
        msg: element.cost
        position: [element.position[0] + 24, element.position[1] + 35]
        size: '28px'
        fill: @blank
        align: 'center'

  cityDetailOrigin: =>
    [ @context.canvas.width / 2, 60 ]

  renderCityDetail: (city) =>
    origin = @cityDetailOrigin()
    @rect
      position: [origin[0] - 155, origin[1] - 20]
      size: [310, 140]
      fill: @accent

    @text
      msg: city.name
      position: [origin[0], origin[1] + 45]
      size: '48px'
      align: 'center'
      fill: 'white'

    @text
      msg: "Population: #{city.population.length}"
      position: [origin[0], origin[1] + 90]
      size: '24px'
      align: 'center'
      fill: 'white'

  renderResources: (city) =>
    origin = [ 10, 30 ]
    @rect
      position: origin
      size: [360, 240]
      fill: @blank

    @text
      msg: "Resources"
      position: [origin[0] + 20, origin[1] + 50]
      size: '36px'

    row = 0
    for resource of city.resources
      quantity = city.resources[resource]
      rate = city.computeCollectionRateFor(resource)
      rate_description = (if rate > 0 then "(+#{rate}/s)" else '')
      @rect
        position: [origin[0] + 20, origin[1] + 70 + (37 * row)]
        size: [80, 37]
        fill: @accent
 
      @text
        msg: resource
        position: [origin[0] + 30, origin[1] + 100 + (37 * row)]
        size: '28px'

      @rect
        position: [origin[0] + 100, origin[1] + 70 + (37 * row)]
        size: [220, 37]
        fill: @contrast

      @text
        msg: "#{quantity} #{rate_description}"
        position: [origin[0] + 120, origin[1] + 100 + (37 * row)]
        size: '28px'

      row = row + 1

  renderTime: (world) =>
    origin = [(@context.canvas.width / 2) - 120, @context.canvas.height * 0.125]
    @rect
      position: origin
      size: [240, 100]
      fill: @blank

    @rect
      position: [origin[0] + 5, origin[1] + 5]
      size: [230, 90]
      fill: @accent

    @text
      msg: world.describeTime()
      position: [origin[0] + 120, origin[1] + 45]
      size: '36px'
      align: 'center'

    @text
      msg: world.describeDate()
      position: [origin[0] + 120, origin[1] + 80]
      size: '28px'
      align: 'center'

