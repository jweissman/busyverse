class Busyverse.Support.Randomness
  valueInRange: (range) ->
    Math.floor Math.random() * range

  valueFromList: (list) ->
    list[@valueInRange(list.length)]

  # valueFromPercentageMap: (map) ->


    
