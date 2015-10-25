//= require busyverse
//= require support/geometry
//= require support/pathfinding
//= require grid
//= require agent
onmessage = function(message) {
  console.log("Worker.js -- onmessage!!!");
  postMessage(Busyverse.Agent.handleCommand(message)); //findPath(message.data));
};
