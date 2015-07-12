class Busyverse.Support.Randomness
  valueInRange: (range) ->
    Math.floor Math.random() * range

  valueFromList: (list) ->
    list[@valueInRange(list.length)]

  valueFromPercentageMap: (map) ->
    percentages = Object.keys(map)
    total = 0
    for percentage in percentages
      total = total + parseInt percentage

    val = @valueInRange total
    sum = 0
    for percentage in percentages
      sum = sum + parseInt percentage
      if sum >= val
        return map[percentage]
    


    
