'use strict';
function repeat(player, {mode}) {
  if (mode === "on") {
    mode = "all";
  } else if (mode === "off") {
    mode = "none";
  }

  return player.coordinator.repeat(mode);
}

function shuffle(player, {state="off"}) {
  return player.coordinator.shuffle(state == "on" ? true : false);
}

function crossfade(player, {state="off"}) {
  return player.coordinator.crossfade(state == "on" ? true : false);
}

module.exports = function (api) {
  api.registerAction('repeat', repeat);
  api.registerAction('shuffle', shuffle);
  api.registerAction('crossfade', crossfade);
}