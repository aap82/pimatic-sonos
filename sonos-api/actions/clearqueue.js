'use strict';

function clearQueue(player) {
  return player.coordinator.clearQueue();
}

module.exports = function (api) {
  api.registerAction('clearQueue', clearQueue);
};