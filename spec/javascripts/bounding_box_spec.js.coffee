#= require busyverse
#= require bounding_box

describe "BoundingBox", ->
  describe ".hit", ->
    it 'should detect hits within bounds', ->
      size = { x: 100, y: 100 }
      box = new Busyverse.BoundingBox("a box", [0,0], [size.x,size.y])
      inside_box  = [ size.x - 10, size.y - 10 ]
      outside_box = [ size.x + 1,  size.y + 1 ]
      box.hit(inside_box).should.equal(true)
      box.hit(outside_box).should.equal(false)
