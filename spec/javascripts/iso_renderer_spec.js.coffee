#= require busyverse
#= require isomer
#= require iso_renderer

context "Busyverse.IsoRenderer", ->
  beforeEach ->
    context = {}
    @canvas = {
      getContext: -> context
      getBoundingClientRect: -> { left: 1, top: 1 }
      addEventListener: ->
    }

    @renderer = new Busyverse.IsoRenderer(@canvas)

  describe "getMousePos", ->
    it 'computes mouse position', ->
      event = { clientX: 10, clientY: 10 }
      actual_mouse = @renderer.getMousePos(@canvas, event)
      expected_mouse = { x: 9, y: 9 }
      expect(actual_mouse).to.eql(expected_mouse)
      
