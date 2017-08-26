'use strict';

function playlist(player, {name}) {
  return player.coordinator
               .replaceWithPlaylist(name)
               .then(() => player.coordinator.play());
}

module.exports = function (api) {
  api.registerAction('playlist', playlist);
};
