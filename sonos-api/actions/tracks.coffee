module.exports = (env, api) ->
  previous = (player) -> return player.coordinator.previousTrack().catch((err) => return api.errAction("nextTrack", err))
  next = (player) -> return player.coordinator.nextTrack().catch((err) => return api.errAction("previousTrack", err))

  addTrack = (player, uri=null) =>
    return unless uri?
    return player.coordinator.addURIToQueue(uri).catch((err) => return api.errAction("addTrack", err))

  removeTrack = (player, trackNumber=null) =>
    return unless trackNumber?
    return player.coordinator.removeTrackFromQueue(trackNumber).catch((err) => return api.errAction("removeTrack", err))
  setTrack = (player, trackNumber=null) =>
    return unless trackNumber?
    console.log trackNumber
    return player.coordinator.trackSeek(trackNumber).catch((err) => api.errAction("setTrack", err))

  return {
    previous:
      execute: previous
      action:
        description: "Select previous track, but will not play if sonos player not playing"
      predicates: [
        "select previous track on sonos player "
      ]
    next:
      execute: next
      action:
        description: "Select next track, but will not play if sonos player not playing"
      predicates: [
        "select next track on sonos player "
      ]

    addTrack:
      execute: addTrack
    removeTrack:
      execute: removeTrack
    setTrack:
      execute: setTrack


  }








