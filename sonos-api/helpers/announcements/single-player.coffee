module.exports = (env) ->

  Promise = env.require 'bluebird'
  isRadioOrLineIn = require('../is-radio-or-line-in')
  backupPresets = {}
  singlePlayerAnnouncement = (player, uri, volume) =>
    playerState = player.state
    system = player.system
    groupToRejoin = undefined
    backupPreset = players: [ {
      roomName: player.roomName
      volume: playerState.volume
    } ]
    if player.coordinator.uuid is player.uuid
      group = system.zones.find((zone) => zone.coordinator.uuid is player.coordinator.uuid)
      console.log group.members[0].roomName
      if group.members.length > 1
        console.log 'Think its coordinator, will find uri later'
        groupToRejoin = group.id
        backupPreset.group = group.id
      else
        backupPreset.state = playerState.playbackState
        backupPreset.uri = player.avTransportUri
        backupPreset.metadata = player.avTransportUriMetadata
        backupPreset.playMode = repeat: playerState.playMode.repeat
        if !isRadioOrLineIn(backupPreset.uri)
          backupPreset.trackNo = playerState.trackNo
          backupPreset.elapsedTime = playerState.elapsedTime
    else
      backupPreset.uri = "x-rincon:#{player.coordinator.uuid}"

    env.logger.debug 'backup state was', backupPreset
    ttsPreset =
      players: [ {
        roomName: player.roomName
        volume: volume
      } ]
      playMode: repeat: false
      uri: uri

    announceFinished = null
    afterPlayingStateChange = null
    abortTimer = undefined
  
    onTransportChange = (state) =>
      unless announceFinished isnt null
        return
      env.logger.debug "playback state switched to #{state.playbackState}"
      if state.playbackState is 'STOPPED' and afterPlayingStateChange isnt null
        env.logger.debug 'announcement finished because of STOPPED state identified'
        afterPlayingStateChange()
        afterPlayingStateChange = null
        return
      if state.playbackState is "PLAYING"
        afterPlayingStateChange = announceFinished
      abortDelay = player._state.currentTrack.duration + 2
      clearTimeout abortTimer
      env.logger.debug "Setting restore timer for #{abortDelay} seconds"
      abortTimer = setTimeout((=>
        if announceFinished isnt null
          return announceFinished()
        return
      ), abortDelay * 1000)
      player.once 'transport-state', onTransportChange
  
    if not backupPresets[player.roomName]?
      backupPresets[player.roomName] = []
    backupPresets[player.roomName].unshift backupPreset



    prepareBackupPreset = =>
      return new Promise (resolve,reject) =>
        if backupPresets[player.roomName].length > 1
          env.logger.debug 'more than 1 backup presets during prepare', backupPresets[player.roomName]
          backupPresets[player.roomName].shift()
          return resolve()
        if backupPresets[player.roomName].length < 1
          return resolve()
        relevantBackupPreset = backupPresets[player.roomName][0]
        env.logger.debug 'exactly 1 preset left', relevantBackupPreset
        if relevantBackupPreset.group
          zone = system.zones.find((zone) => zone.id is relevantBackupPreset.group)
          if zone
            relevantBackupPreset.uri = "x-rincon:#{zone.uuid}"
        env.logger.debug 'applying preset', relevantBackupPreset
        system.applyPreset(relevantBackupPreset).then =>
          backupPresets[player.roomName].shift()
          console.log 'after backup preset applied', backupPresets[player.roomName]
          return resolve()
        .catch (err) =>
          reject(err)





    doSay = system.applyPreset(ttsPreset).then =>
        player.once 'transport-state', onTransportChange
        return new Promise (resolve) =>
          announceFinished = resolve
          return
      .then =>
        clearTimeout abortTimer
        announceFinished = null
      .then(prepareBackupPreset)
      .then(=> Promise.resolve())
      .catch (err) =>
        env.logger.error err
        prepareBackupPreset().then =>
          throw err
          return Promise.reject()

    return doSay
  
  
  
  return singlePlayerAnnouncement
