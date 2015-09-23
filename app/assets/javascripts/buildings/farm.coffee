#= require busyverse
#= require buildings/building

class Busyverse.Buildings.Farm extends Busyverse.Building
  name: 'Small Farm'
  size: [3, 3, 0.1]
  color: { red: 160, green: 20, blue: 20 }
  costs:
    'wood': 2
