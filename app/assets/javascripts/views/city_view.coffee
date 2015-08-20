#= require views/view
class Busyverse.Views.CityView extends Busyverse.View
  render: (world) =>
    city = @model

    cover = [Busyverse.width * Busyverse.cellSize,
             Busyverse.height * Busyverse.cellSize]

    if world.isDay() 
      percentOfDay = world.percentOfDay()
      alpha = percentOfDay
      if percentOfDay >= 0.5
        alpha = 1.0 - percentOfDay

      @rect
        position: [0,0]
        size: cover
        fill: "rgba(128,128,0,#{alpha})"
    else
      @rect
        position: [0,0]
        size: cover
        fill: "rgba(0,0,192,0.125)"

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


    @rect
      position: [200, 10]
      size: [240, 40]
      fill: 'ivory'

    @text
      msg: world.describeTime()
      position: [203, 35]
      size: '20px'

  
