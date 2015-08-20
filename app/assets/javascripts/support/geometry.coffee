class Busyverse.Support.Geometry
  euclideanDistance: (a, b) => 
    # console.log "Geometry#euclideanDistance a=#{a}, b=#{b}"
    a1 = a[0]
    a2 = a[1]
    b1 = b[0]
    b2 = b[1]

    dx = Math.abs(b1 - a1)
    dy = Math.abs(b2 - a2)

    Math.sqrt( (dx*dx) + (dy*dy) )

  # pickClosestTo: (a*b)
