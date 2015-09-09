#= require views/view

# TODO rename WidgetView
class Busyverse.Views.UIView extends Busyverse.View
  render: (world) =>
    city = @model

    @renderCover(world)
    @renderUi(world, city)

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

  renderUi: (world, city) =>      
    @renderCityDetail(city)
    @renderTime(world)
    @renderBuildingPalette(city)

  renderBuildingPalette: (city) =>
    @rect 
      position: [10,115]
      size: [150, 100]
      fill: 'ivory'

    building_list = [ new Busyverse.Buildings.Farm(), 
                      new Busyverse.Buildings.House(), 
                      new Busyverse.Buildings.Tower() ]

    building_index = 0
    for building in building_list
      selected = building.name == 'Small Farm'
      affordable = city.canAfford building

      color = if selected 
        'lightgreen' 
      else 
        if affordable then 'forestgreen' else 'grey'

      @rect
        position: [13, 120 + building_index * 30 ]
        size: [ 143, 28 ]
        fill: color

      @text 
        msg: building.name
        position: [14,140 + building_index * 30]
        size: '24px'

      building_index = building_index + 1

  renderCityDetail: (city) =>
    @rect 
      position: [10,10]
      size: [160, 100]
      fill: 'ivory'

    @text 
      msg: city.name
      position: [12,33]
      size: '24px'

    @rect
      position: [15, 40]
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
      position: [200, 10]
      size: [240, 40]
      fill: 'ivory'

    @text
      msg: world.describeTime()
      position: [200, 35]
      size: '20px'

  
