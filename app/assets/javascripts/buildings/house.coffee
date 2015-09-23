#= require busyverse
#= require buildings/building

class Busyverse.Buildings.House extends Busyverse.Building
  name: 'Residence'
  size: [2,2,2]
  color: { red: 160, green: 240, blue: 130 }
  costs:
    'wood': 3
