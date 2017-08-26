'use strict';
function volume(player, {level}) {
  return player.setVolume(level);
}

function groupVolume(player, {level}) {
  return player.coordinator.setGroupVolume(level);
}

module.exports = function (api) {
  api.registerAction('volume', volume);
  api.registerAction('groupvolume', groupVolume);
}