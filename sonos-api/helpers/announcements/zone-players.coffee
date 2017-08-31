{readyPlayer,readyPlayers} = require './checks'
{applyStateToSystem} = require '../apply-states'
isRadioOrLineIn = require '../is-radio-or-line-in'

announceState =
  playbackState: false
  playMode:
    shuffle: no
    repeat: 'none'

zonePlayerAnnouncement = (api, player, uri, volume, group) =>
  console.log 'ok'
  coordinator = player.coordinator
  members = group.members
  trackNumber = null
  announceFinished = null
  afterPlayingStateChange = null
  abortTimer = null

  currentState =
    uri: coordinator.avTransportUri
    playbackState: coordinator.state.playbackState
    trackNo: coordinator.state.trackNo
    players: {}

  currentState.playerStates[m.uuid] = {volume: m.state.volume, mute: m.state.mute} for m in members

  if not isRadioOrLineIn(currentState.uri)
    currentState.elapsedTime= coordinator.state.elapsedTime
    currentState.playMode= coordinator.state.playMode


#
#  promise = applyStateToSystem(api, currentState.players, {pauseOthers: yes})
#  console.log 'hi'
  return promise.then(=> Promise.resolve()).catch((err) => console.log(err))



  onTransportChange = (state) =>
    unless announceFinished isnt null
      return
    if state.playbackState is 'STOPPED' and afterPlayingStateChange isnt null
      afterPlayingStateChange()
      afterPlayingStateChange = null
      return
    if state.playbackState is "PLAYING"
      afterPlayingStateChange = announceFinished
    abortDelay = player._state.currentTrack.duration + 2
    clearTimeout abortTimer
    abortTimer = setTimeout((=>
      if announceFinished isnt null
        announceFinished()
      return
    ), abortDelay * 1000)
    player.once 'transport-state', onTransportChange



  reject = (err) =>
    api.setAnnounce(no)
    return Promise.reject(err)




  doAnnounceZone = api.actions.addTrack(player, uri)
    .then((t) =>
      console.log t
      trackNumber = t.firsttracknumberenqueued
    )
    .then(=> api.actions.pause(player))
    .then(=> api.actions.setPlayModes(player, {repeat: "none", shuffle: false}))
    .then(=> readyPlayer(player, announceState))
    .then(=> api.actions.mutePlayers(members, false))
    .then(=> api.actions.volumePlayers(members, volume ))
    .then(=> api.actions.setTrack(player, trackNumber))
    .then(=> readyPlayers(player, {mute: no, volume: volume}))
    .then(=> api.actions.play(player))
    .then =>
      player.once 'transport-state', onTransportChange
      return new Promise (resolve) =>
        announceFinished = resolve
        return
    .then =>
      clearTimeout abortTimer
      announceFinished = null
    .then(restoreState)
    .then(=> api.actions.removeTrack(player, trackNumber))
    .then(=> trackNumber=null)

    .then  =>
      api.setAnnounce(no)
      Promise.resolve()
    .catch (err) =>
      console.log err
      promise = Promise.resolve()
      if trackNumber
        promise = promise
          .then(=>api.actions.removeTrack(player, trackNumber))
          .then(=> trackNumber=null; return)
          .catch (err) =>
            trackNumber = null
            Promise.reject(err)
      return promise.then(=> reject(err)).catch(reject)


  return doAnnounceZone


module.exports = zonePlayerAnnouncement

#restoreStatePromise = =>
#  return new Promise((resolve) =>
#    onStateChange = (state) =>
#      {playMode} = state
#      if state.volume is volume and not state.mute and
#        playMode.repeat is "none" and not playMode.shuffle
#        return resolve()
#      coordinator.once 'transport-state', onStateChange
#    coordinator.once 'transport-state', onStateChange
#  )