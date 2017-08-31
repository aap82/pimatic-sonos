module.exports = (env, api) ->
  Promise = env.require 'bluebird'

  play = (player) ->
    return if player.coordinator.state.playbackState.toLowerCase() is 'playing'
    return player.coordinator.play().catch((err) => api.errAction("play", err))
  pause = (player) ->
    return unless player.coordinator.state.playbackState.toLowerCase() is 'playing'
    return player.coordinator.pause().catch((err) => api.errAction("pause", err))
  playPause = (player) ->
    return pause(player) if player.coordinator.state.playbackState.toLowerCase() is 'playing'
    return play(player)

  return {
    play:
      execute: play
      action:
        description: "Starts playing"
      predicates: [
        "play sonos player "
      ]
    pause:
      execute: pause
      action:
        description: "Pauses playing"
      predicates: [
        "pause sonos player "
      ]
    playPause:
      execute: playPause
      action:
        description: "Toggles the play pause state"
      predicates: [
        "toggle play/pause of sonos player "
      ]

  }








