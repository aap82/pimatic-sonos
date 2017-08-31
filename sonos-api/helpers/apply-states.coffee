coordinatorState = (player, system) ->
  playbackState: player.playbackState or 'STOPPED'

  player.uuid
  avTransportUri: player.avTransportUri
  metadata: player.avTransportUriMetadata

playerState = (player, system) ->
  {state} = player


saveState = (player) ->




createStates = (system, systemState) =>
  return new Promise (resolve, reject) ->
    {
      all=false,
      current=false
      playmode = null
      playbackState = 'PLAYING'
      pauseOthers=no,
      overrideRadio=no,
      forceUnMute=no,
      playerStates={}
    } = systemState

    if not all and players is {}
      return reject("i have no i dea what I'm suppose to do")

    uuids = (key.uuid for key, value of players)

    newState = {}
    for zone in system.zones
      for m in zone.members
        uuid = m.uuid
        if all or pauseOthers or
        uuid in uuids
          newState[uuid] = {}
        return unless newState[uuid]?









applyStateToSystem = (api, systemState={}) ->
  system = api.system
  states = createStates(system, systemState)

  currentState = null
  nextState = {}
  uuids = []


  nextState = createStates()


  players = switch pauseOthers
    when yes then system.players
    else (system.getPlayerByUUID(uuid) for uuid in uuids)
  state = createStates(players, states, options)
  return Promise.resolve()








module.exports = {
    applyStateToSystem
  }