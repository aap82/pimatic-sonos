setPlayerVolume = (player, level) ->
  level = if level.includes(' ') or level.includes('-')
      player.state.volume + parseInt(level)
    else
      parseInt(level)
  if level < 1 then level = 0
  if level > 100 then level = 100
  return player.setVolume(level)

setGroupVolume = (player, level) ->

volume = (player, {level=null, group=false}) ->
  return Promise.resolve() unless level?
  switch group
    when no then return setPlayerVolume(player,level)
    else return
  return player.coordinator.setGroupVolume(volume) if group

module.exports = volume