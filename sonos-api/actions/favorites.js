'use strict';

function favorites(player, {detailed=no}) {

  return player.system.getFavorites()
    .then((favorites) => {

      if (detailed) {
        return favorites;
      }

      // only present relevant data
      return favorites.map(i => i.title);
    });
}

module.exports = function (api) {
  api.registerAction('favorites', favorites);
  api.registerAction('favourites', favorites);
};
