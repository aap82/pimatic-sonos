'use strict';
var pausedPlayers = [];

function pauseAll(player, {timeout=null}) {
  console.log("pausing all players");
  // save state for resume

  if (timeout && timeout > 0) {
    console.log("in", timeout, "minutes");
    setTimeout(function () {
      doPauseAll(player.system);
    }, timeout * 1000 * 60);
    return Promise.resolve();
  }

  return doPauseAll(player.system);
}

function resumeAll(player, {timeout=null}) {
  console.log("resuming all players");

  if (timeout && timeout > 0) {
    console.log("in", timeout, "minutes");
    setTimeout(function () {
      doResumeAll(player.system);
    }, timeout * 1000 * 60);
    return Promise.resolve();
  }

  return doResumeAll(player.system);
}

function doPauseAll(system) {
  pausedPlayers = [];
  const promises = system.zones
    .filter(zone => {
      console.log(zone.coordinator.state)
      return zone.coordinator.state.playbackState === 'PLAYING'
    })
    .map(zone => {
      console.log(zone.uuid)
      pausedPlayers.push(zone.uuid);
      const player = system.getPlayerByUUID(zone.uuid);
      return player.pause();
    });
  return Promise.all(promises);
}

function doResumeAll(system) {

  const promises = pausedPlayers.map(uuid => {
    var player = system.getPlayerByUUID(uuid);
    return player.play();
  });

  // Clear the pauseState to prevent a second resume to raise hell
  pausedPlayers = [];

  return Promise.all(promises);
}


module.exports = function (api) {
  api.registerAction('pauseall', pauseAll);
  api.registerAction('resumeall', resumeAll);
}