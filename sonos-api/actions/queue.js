'use strict';

function simplify(items) {
  return items
  .map(item => {
    return {
      title: item.title,
      artist: item.artist,
      album: item.album,
      albumArtUri: item.albumArtUri
    }
  });
}

function queue(player, {detailed = false, limit = 5, offset = 0}) {
  const promise = player.coordinator.getQueue(limit, offset);

  if (detailed) {
    return promise;
  }

  return promise.then(simplify);
}

module.exports = function (api) {
  api.registerAction('queue', queue);
}
