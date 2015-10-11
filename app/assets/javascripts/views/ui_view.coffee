#= require views/view

class Busyverse.Views.UIView extends Busyverse.View
  blank: 'whitesmoke'
  primary: 'skyblue'
  secondary: 'blanchedalmond'
  accent: 'rgba(80,0,80,0.25)'
  contrast: 'powderblue'

  render: (world) =>
    city = @model

    @renderCover(world)
    @renderUi(world, city)

  renderUi: (world, city) =>
    @renderCityDetail(city)
    @renderTime(world)
    @renderResources(city)
    @renderBuildingPalette(city)
    @renderTips()

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

  paletteOrigin: => [ @context.canvas.width - 380, 150 ]
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
        position: [element.position[0] + 20, element.position[1] + 35]
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
      msg: "Pop: #{city.population.length}"
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
    origin = [(@context.canvas.width / 2) - 120, @context.canvas.height * 0.9]
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

  renderTips: =>
    @renderListWidget 'Controls', @controlOrigin, Busyverse.tips
    @renderListWidget 'Commands', @commandOrigin, Busyverse.commands

  controlOrigin: [10,300]
  commandOrigin: [10,600]

  renderListWidget: (name, origin, items) =>
    height = 50 + (30 * items.length)

    @rect
      position: origin
      size: [350, height + 110]
      fill: @blank

    @text
      msg: name
      position: [origin[0] + 25, origin[1] + 50]
      size: '36px'

    @rect
      position: [origin[0] + 25, origin[1] + 80]
      size: [290, height]
      fill: @primary

    item_index = 0
    for message in items
      @text
        msg: message
        position: [ origin[0] + 50, origin[1] + 120 + (30 * item_index) ]
        size: '26px'
      item_index = item_index + 1
