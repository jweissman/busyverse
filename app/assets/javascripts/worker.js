onmessage = function(message) {
  console.log("worker.js #onmessage message: ");
  console.log(message);

  postMessage(Busyverse.findPath( message.data));
};

//class Busyverse.Worker
//  done: false
//  constructor: ->
//    console.log "Worker.coffee!"
//
//class Busyverse.Worker.Pathfinder extends Busyverse.Worker
//  constructor: ->
//    console.log "New pathfinder worker!"
//
//  findPath: (map: map, src: src, tgt: tgt) ->
//    console.log "!!!!!!!!!!!!!!!!!!!!!!!!!!!"
//    console.log "Worker.Pathfinder#findPath"
//
//console.log "from worker.coffee"
//onmessage = (e) ->
//  console.log "WORKER GOT MESSAGE"
//
//# Busyverse.pathfinder = new Busyverse.Worker.Pathfinder()
//# Busyverse.pathfinder.run()
//# Busyverse.pathfinder.onmessage = (problem) ->
//#   console.log "worker onmessage"
//#   console.log data
//#   Busyverse.pathfinder.findPath(problem)

