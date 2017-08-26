'use strict';
function playlists(player, {detailed=false}) {

  return player.system.getPlaylists()
    .then((playlists) => {
      if (detailed) {
        return playlists;
      }

      // only present relevant data
      var simplePlaylists = [];
      playlists.forEach(function (i) {
        simplePlaylists.push(i.title);
      });

      return simplePlaylists;
    });
}

module.exports = function (api) {
  api.registerAction('playlists', playlists);
}
