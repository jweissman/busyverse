onmessage = function(message) {
  // console.log("worker.js #onmessage message: ");
  // console.log(message);

  postMessage(Busyverse.findPath( message.data));
};
