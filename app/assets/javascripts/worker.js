onmessage = function(message) {
  postMessage(Busyverse.findPath(message.data));
};
