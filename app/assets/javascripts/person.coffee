class Busyverse.Person
  size: [10,10]
  
  speed: 1
  velocity: [0,0]

  constructor: (@name, @position, @activeTask) ->
    @position ?= [0,0]
    @activeTask ?= "idle"
    console.log "new person (#{@name}) created at #{@position}" if Busyverse.debug

  send: (cmd) => 
    console.log "updating #{@name}'s active task to #{cmd}" if Busyverse.debug
    if cmd == "wander" or cmd == "idle" or cmd == "build"
      @activeTask = cmd
      @destination = null

      return "Now doing #{@activeTask}"
    else
      return "Unknown command #{cmd}"

  update: (world, city) =>
    console.log "Person#update called!" if Busyverse.debug and Busyverse.verbose

    if @activeTask == "wander"
      @wander(world)
    else if @activeTask == "build"
      @build(world, city)

    if @activeTask != "idle"
      @move() 

  move: =>
    @position[0] = @position[0] + @velocity[0]
    @position[1] = @position[1] + @velocity[1]

  build: (world, city) =>
    @destination ?= world.randomLocation()
    @seek()
    if Math.abs(@destination[0] - @position[0]) < 10 and 
       Math.abs(@destination[1] - @position[1]) < 10
      console.log "CREATING BUILDING AT #{@position}" if Busyverse.debug
      city.create(new Busyverse.Buildings.Farm(@position.slice(0)))
      @activeTask = "idle"

  wander: (world) =>
    @destination ?= world.randomLocation()
    @velocity    = [0,0]

    console.log "Going to #{@destination}"

    @seek() #@destination)

    if @destination[0] == @position[0] and @destination[1] == @position[1]
      @destination = world.randomLocation()

  seek: () =>
    if @destination[0] < @position[0]
      @velocity[0] = -@speed
    else if @destination[0] > @position[0]
      @velocity[0] = @speed
    
    if @destination[1] < @position[1]
      @velocity[1] = -@speed
    else if @destination[1] > @position[1]
      @velocity[1] = @speed


  # build: =>
  #   @currentlyBuilding ?= 

