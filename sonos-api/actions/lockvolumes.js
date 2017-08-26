'use strict';
const logger = require('sonos-discovery/lib/helpers/logger');
const lock_volumes = {};

function lockVolumes(player) {
  logger.debug('locking volumes');
  // Locate all volumes
  var system = player.system;

  system.players.forEach((player) => {
    lock_volumes[player.uuid] = player.state.volume;
  });

  // prevent duplicates, will ignore if no event listener is here
  system.removeListener('volume-change', restrictVolume);
  system.on('volume-change', restrictVolume);
  return Promise.resolve();
}

function unlockVolumes(player) {
  logger.debug('unlocking volumes');
  var system = player.system;
  system.removeListener('volume-change', restrictVolume);
  return Promise.resolve();
}

function restrictVolume(info) {
  logger.debug(`should revert volume to ${lock_volumes[info.uuid]}`);
  const player = this.getPlayerByUUID(info.uuid);
  // Only do this if volume differs
  if (player.state.volume != lock_volumes[info.uuid])
    return player.setVolume(lock_volumes[info.uuid]);
}

module.exports = function (api) {
  api.registerAction('lockVolumes', lockVolumes);
  api.registerAction('unlockVolumes', unlockVolumes);
}