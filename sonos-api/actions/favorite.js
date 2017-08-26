'use strict';
function favorite(player, {name}) {
  return player.coordinator.replaceWithFavorite(name)
               .then(() => player.coordinator.play());
}

module.exports = function (api) {
  api.registerAction('favorite', favorite);
  api.registerAction('favourite', favorite);
}
