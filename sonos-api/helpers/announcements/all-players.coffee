module.exports = (env) ->
  backupPresets = {}
  Promise = env.require 'bluebird'
  isRadioOrLineIn = require('../is-radio-or-line-in')
  saveAll = (system) =>
    backupPresets = system.zones.map((zone) =>
      coordinator = zone.coordinator
      state = coordinator.state
      preset =
        players: [ {
          roomName: coordinator.roomName
          volume: state.volume
        } ]
        state: state.playbackState
        uri: coordinator.avTransportUri
        metadata: coordinator.avTransportUriMetadata
        playMode: repeat: state.playMode.repeat

      if !isRadioOrLineIn(preset.uri)
        preset.trackNo = state.trackNo
        preset.elapsedTime = state.elapsedTime
      zone.members.forEach (player) =>
        if coordinator.uuid != player.uuid
          preset.players.push
            roomName: player.roomName
            volume: player.state.volume
        return
      preset
    )

    backupPresets.sort (a, b) =>
      a.players.length < b.players.length

  announceAll = (system, uri, volume) =>
    abortTimer = null
    # Save all players
    backupPresets = saveAll(system)
    # find biggest group and all players
    allPlayers = []
    biggestZone = {}
    system.zones.forEach (zone) =>
      if !biggestZone.members or zone.members.length > biggestZone.members.length
        biggestZone = zone

    coordinator = biggestZone.coordinator
    allPlayers.push
      roomName: coordinator.roomName
      volume: volume

    system.players.forEach (player) =>
      if player.uuid is coordinator.uuid
        return
      allPlayers.push
        roomName: player.roomName
        volume: volume
    return

    preset =
      uri: uri
      players: allPlayers
      playMode: repeat: false
      pauseOthers: true
      state: 'STOPPED'
    announceFinished = null
    afterPlayingStateChange = null
    abortTimer = undefined

    onTransportChange = (state) =>
      unless announceFinished isnt null
        return
      if state.playbackState is 'STOPPED' and afterPlayingStateChange isnt null
        afterPlayingStateChange()
        afterPlayingStateChange = null
        return
      if state.playbackState is 'PLAYING'
        afterPlayingStateChange = announceFinished
      abortDelay = coordinator._state.currentTrack.duration + 2
      clearTimeout abortTimer
      abortTimer = setTimeout((=>
        if announceFinished isnt null
          return announceFinished()
        return
      ), abortDelay * 1000)
      coordinator.once 'transport-state', onTransportChange

    oneGroupPromise = new Promise((resolve) =>
      onTopologyChanged = (topology) =>
        if topology.length is 1
          return resolve()
        system.once 'topology-change', onTopologyChanged

      system.once 'topology-change', onTopologyChanged
    )

    doSayAll = system.applyPreset(preset).then =>
        return if system.zones.length is 1
        return oneGroupPromise
      .then =>
        coordinator.once 'transport-state', onTransportChange
        coordinator.play()
        return new Promise (resolve) =>
          announceFinished = resolve
      .then =>
        clearTimeout abortTimer
        announceFinished = null
      .then =>
        return backupPresets.reduce (promise, preset) =>
          return promise.then =>
            return system.applyPreset preset
        , Promise.resolve()
      .catch (err) =>
        throw err
        return Promise.reject()

    return doSayAll


  return announceAll
