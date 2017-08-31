checkPlayer = (obj, target) =>
  for key, value of target
    if key is 'playMode' and obj.playMode?
      for attr, mode of value
        if obj.playMode[attr] isnt mode
          return false
    else if key is 'playbackState'
      return false if target.playbackState and (obj.playbackState isnt 'PLAYING')
      return false if not target.playbackState and (obj.playbackState is 'PLAYING')
    else if obj[key] isnt value
      return false
  return true

checkPlayers = (uuid, system, targets) =>
  for zone in system.zones when zone.coordinator.uuid is uuid
    for p in zone.members
      target = targets[p.uuid] or targets
      player = system.getPlayerByUUID(p.uuid)
      if not checkPlayer(player.state, target)
        return false
    return true



readyPlayer =  (player, target) =>
  return new Promise((resolve) =>
    return resolve() if checkPlayer(player.state, target)
    onStateChange = (state) =>
      return resolve() if checkPlayer(state, target)
      player.once 'transport-state', onStateChange
    player.once 'transport-state', onStateChange
  )

readyPlayers = (player, target) =>
  return new Promise((resolve) =>
    onStateChange = (state) =>
      system = player.system
      return resolve() if checkPlayers(uuid, system, target)
      system.once 'transport-state', onStateChange
    uuid = player.coordinator.uuid
    system = player.system
    return resolve() if checkPlayers(uuid, system, target)
    system.once 'transport-state', onStateChange
  )

module.exports = {
  readyPlayer
  readyPlayers
}