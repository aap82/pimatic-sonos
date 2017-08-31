module.exports = (env, api) ->
  Promise = env.require 'bluebird'

  _getLevel = (volume, level) ->
    _level = if level.includes(' ') or level.includes('-')
        volume + parseInt(level)
      else
        parseInt(level)
    if _level < 1 then _level = 0
    if _level > 100 then _level = 100
    _level



  setVolume = (player, level) ->
    return Promise.resolve() if player.state.volume is level
    return player.setVolume(level).catch((err) => return api.errAction("play", err))


  volumePlayer = (player, level) ->
    return setVolume(player, _getLevel(player.state.volume, level))

  volumePlayers = (players, volumes = {}) ->
    promises = []
    volume = if typeof volumes in ['string', 'number'] then volumes else null
    for player in players
      volume = volume or volumes[player.uuid]
      promises.push volumePlayer(player, "#{volume}") if volume?
    return Promise.all(promises)

  return {
    volumePlayer:
      execute: volumePlayer
      action:
        description: "Set volume of player"
        params:
          level:
            type: "string"
    volumePlayers:
      execute: volumePlayers
      action:
        description: "Set volume of player"
        params:
          level:
            type: "string"



  }








