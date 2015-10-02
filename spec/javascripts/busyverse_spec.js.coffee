#= require busyverse
#= require engine
#= require game
#= require kickstart

describe "Busyverse", ->
  describe ".kickstart", ->
    it 'should safely fire up the engines', ->
      worker = { postMessage: -> }
      Busyverse.createWorker = -> worker
      expect(Busyverse.kickstart()).to.eql(true)

      # kickstart instruments window.onload, so let's call that?
      window.onload()

