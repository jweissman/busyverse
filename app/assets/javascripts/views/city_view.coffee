#= require views/view
class Busyverse.Views.CityView extends Busyverse.View
  render: (world) =>
    city = @model
    @rect 
      position: [10,10],
      size: [160, 100],
      fill: 'ivory'

    @text 
      msg: "#{city.name}"
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

