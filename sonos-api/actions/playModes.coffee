module.exports = (env, api) ->
  Promise = env.require 'bluebird'
  repeat = (player, state=false) ->
    if state not in ['all', 'none']
      state = if state then "all" else "none"
    return if player.coordinator.state.playMode.repeat is state
    return player.coordinator.repeat(state).catch((err) => return api.errAction("repeat", err))
  shuffle = (player, state=false) ->
    return if player.coordinator.state.playMode.shuffle is state
    return player.coordinator.shuffle(state).catch((err) => return api.errAction("shuffle", err))
  crossFade = (player, state=false) ->
    return Promise.resolve() if player.coordinator.state.playMode.crossfade is state
    return player.coordinator.crossfade(state).catch((err) => return api.errAction("crossFade", err))
  setPlayModes = (player, mode={}) ->
    {playMode} = player.coordinator.state
    request = {}
    if mode.repeat?
      state = mode.repeat
      if state not in ['all', 'none']
        state = if mode.repeat then 'all' else 'none'
      request.repeat = state if playMode.repeat isnt state

    if mode.shuffle?
      request.shuffle = mode.shuffle if mode.shuffle isnt playMode.shuffle
    if mode.crossfade?
      request.crossfade = mode.crossfade if mode.crossfade isnt playMode.crossfade
    console.log request
    return Promise.resolve() if request is {}
    return player.coordinator.setPlayMode(request).catch((err) => return api.errAction("setPlayMode", err))

  return {
    repeat:
      execute: repeat
      action:
        description: "Set the repeat mode"
        params:
          state:
            optional: yes
            type: "boolean"

      predicates: [
        "play sonos player "
      ]
    shuffle:
      execute: shuffle
      action:
        description: "Pauses playing"
      predicates: [
        "pause sonos player "
      ]
    crossFade:
      execute: crossFade
      action:
        description: "Toggles the play pause state"
      predicates: [
        "toggle play/pause of sonos player "
      ]
    setPlayModes:
      execute: setPlayModes

  }








