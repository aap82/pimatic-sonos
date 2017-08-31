module.exports = (env) ->
  Promise = env.require 'bluebird'
  attributes = require './attributes'

  class SonosPlayer extends env.devices.Device
    template: 'musicplayer'

    attributes: attributes
#    actions: actions

    _state: null
    _currentTitle: null
    _currentArtist: null
    _volume: null
    _mute: null

    getState: () -> Promise.resolve @_state
    getCurrentTitle: () -> Promise.resolve(@_currentTitle)
    getCurrentArtist: () -> Promise.resolve(@_currentArtist)
    getVolume: ()  -> Promise.resolve(@_volume)
    getMute: () -> Promise.resolve(@_mute)



    play: -> @sendCommand "play"
    pause: -> @sendCommand "pause"
    playPause: -> @sendCommand "playPause"
    stop: -> @sendCommand "pause"
    previous: -> @sendCommand "previous"
    next: -> @sendCommand "next"
    mute: -> @sendCommand 'mute'
    unMute: -> @sendCommand 'unMute'
    toggleMute: -> @sendCommand 'toggleMute'
    setVolume: (level) -> @sendCommand "setVolume", level
    say: (text, volume, language) -> @sendCommand "say", {text, volume, language}

    sendCommand: (cmd, values) -> @api.deviceCommand @player, cmd, values



    constructor: (@config, plugin) ->
      @player = null
      @debug = plugin.config.debug
      @id = @config.id
      @name = @config.name
      @uuid = @config.uuid
      @api = plugin.api
      @actions = @api.playerDeviceActions
      super()

      plugin.initApi.then(@init).then (player) =>
        @player = player
        @handleStateUpdate player.state
        return

    init: (system) =>
      player = system.getPlayerByUUID(@uuid)
      @stateChanges = player.on 'transport-state', @handleStateUpdate
      @muteChanges = player.on 'mute-change', @handleMuteUpdate
      @volumeChanges = player.on 'volume-change', @handleVolumeUpdate
      return Promise.resolve(player)

    handleStateUpdate: ({playbackState, mute, volume, currentTrack}) =>
      @setAttribute "state", playbackState
      @setAttribute "volume", volume
      @setAttribute "currentArtist", currentTrack.artist
      @setAttribute "currentTitle", currentTrack.title
      @setAttribute "mute", mute
      return

    handleMuteUpdate: ({uuid, newMute}) =>
      @setAttribute "mute", newMute
      return


    handleVolumeUpdate: ({newVolume}) =>
      @setAttribute "volume", newVolume
      return

    setAttribute: (attributeName, value) =>
      if attributeName is 'state'
        value = switch value
          when "PLAYING" then "play"
          else "pause"
      if @['_' + attributeName] isnt value
        @['_' + attributeName] = value
        return @emit attributeName, value
      return

    destroy: =>
      @player = null
      super()


  return SonosPlayer