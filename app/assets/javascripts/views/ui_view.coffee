#= require views/view

class Busyverse.Views.UIView extends Busyverse.View
  render: (world) =>
    city = @model

    @renderCover(world)
    @renderUi(world, city)

  renderUi: (world, city) =>
    @renderCityDetail(city)
    @renderTime(world)
    @renderBuildingPalette(city)

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
        'lightgreen'
      else
        if affordable then 'forestgreen' else 'grey'
  
      palette.push {
        name: building.name
        position: [13.5, (119.5 + building_index * 30)],
        size: [143, 28]
        fill: color
        clickable: affordable && !selected
      }

      building_index = building_index + 1
    palette

  renderBuildingPalette: (city) =>
    palette = @constructPalette(city)
    @rect
      position: [10.5,115.5]
      size: [150, 10 + palette.length * 30 ]
      fill: 'ivory'

    for element in palette
      @rect
        position: element.position
        size: element.size
        fill: element.fill

      @text
        msg: element.name
        position: [element.position[0] + 4, element.position[1] + 21]
        size: '24px'

  renderCityDetail: (city) =>
    @rect
      position: [10.5,10.5]
      size: [160, 100]
      fill: 'ivory'

    @text
      msg: city.name
      position: [12,33]
      size: '24px'

    @rect
      position: [15.5, 40.5]
      size: [150, 65]
      fill: 'goldenrod'

    row = 0
    for resource of city.resources
      quantity = city.resources[resource]
      @text
        msg: "#{resource}: #{quantity}"
        position: [17, 55 + (15 * row)]
        size: '14px'
      row = row + 1


  renderTime: (world) =>
    @rect
      position: [200.5, 10.5]
      size: [240, 40]
      fill: 'ivory'

    @text
      msg: world.describeTime()
      position: [200, 35]
      size: '20px'

  
