#= require busyverse
#= require buildings/building

class Busyverse.Buildings.House extends Busyverse.Building
  name: 'Residence'
  size: [1,1,1]
  color: { red: 160, green: 240, blue: 130 }
  costs:
    'wood': 3
