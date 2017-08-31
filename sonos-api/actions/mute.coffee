module.exports = (env, api) ->
  Promise = env.require 'bluebird'


  mute = (player) ->
    return if player.state.mute
    return player.mute().catch((err) => api.errAction("mute", err))
  unMute = (player) ->
    return unless player.state.mute
    return player.unMute().catch((err) => return api.errAction("unMute", err))
  toggleMute = (player) ->
    return unMute(player) if player.state.mute
    return mute(player)

  muteGroup = (player) -> player.coordinator.mute().catch((err) => return api.errAction("shuffle", err))
  unMuteGroup = (player) -> player.coordinator.unMute().catch((err) => return api.errAction("shuffle", err))
  mutePlayers = (players, mutes = {}) ->
    promises = []
    for player in players
      _mute = if typeof mutes is 'boolean' then mutes else mutes[player.uuid]
      if _mute in [true, false]
        promises.push mute(player) if _mute
        promises.push unMute(player) if not _mute
    return Promise.all(promises)


  return {
    mute:
      execute: mute
      action:
        description: "Mutes sonos player"
      predicates: [
        "mute sonos player "
      ]
    groupMute:
      execute: muteGroup
      action:
        description: "Mutes sonos player"
      predicates: [
        "mute all sonos players in zone "
      ]
    unMute:
      execute: unMute
      action:
        description: "Un-mutes sonos player"
      predicates: [
        "un-mute sonos player "
      ]
    groupUnMute:
      execute: unMuteGroup
      action:
        description: "Un-mutes sonos player"
      predicates: [
        "un-mute all sonos players in zone "
      ]

    toggleMute:
      execute: toggleMute
      action:
        description: "Toggles the mute state of sonos player"
      predicates: [
        "toggle mute of sonos player "
      ]

    mutePlayers:
      execute: mutePlayers

  }








