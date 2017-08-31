module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  SonosSystem = require('sonos-discovery')
  SonosApi = require('./sonos-api/')(env)
  SonosPlayer = require('./sonos-player-device/sonos-player')(env)
  deviceConfigDef = require('./device-config-schema')
  SonosFileActionProvider = require('./predicates_and_actions/file-action-provider')(env)


  class SonosPlugin extends env.plugins.Plugin
    prepareConfig: (conf) ->
      return unless conf.fileServer.enable and conf.tts.enable
      {tts} = conf
      conf.tts.google.language = tts.language unless tts.google.language?
      if conf.tts.provider is 'voiceRss'
        conf.tts.voiceRss.language = tts.language unless tts.voiceRss.language?
        conf.tts.provider = 'google' unless tts.voiceRss.key?
      return conf

    init: (app, @framework, @config) ->
      @debug = @framework.config.settings.debug or no
      @sonos = new SonosSystem({})
      @api = new SonosApi(@sonos, @config)
      @initApi = @connect(@sonos)

      @framework.deviceManager.registerDeviceClass "SonosPlayer",
        configDef: deviceConfigDef.SonosPlayer,
        createCallback: (config) => return new SonosPlayer(config, @)


      @framework.ruleManager.addActionProvider(
        new SonosFileActionProvider(@framework,@api, @config)
      )


      @framework.deviceManager.on "discover", @discover


    discover: =>
      env.logger.info "Starting Sonos Discovery"
      ids = []
      uuids = []
      for dev in @framework.deviceManager.devicesConfig
        if dev.class is 'SonosPlayer'
          uuids.push dev.uuid
          ids.push dev.id

      @initApi.then =>
        for player in @sonos.players
          if player.uuid not in uuids
            id = "sonos-#{player.roomName.toLowerCase().replace(" ", "-")}"
            if id in ids then id = "#{id}-1"
            if id in ids then id = "#{id}-2"
            config =
              id: id
              name: "Sonos #{player.roomName}"
              uuid: player.uuid
              defaultVolume: @config.fileServer.volume
              class: 'SonosPlayer'
            @framework.deviceManager.discoveredDevice 'sonos-player', "#{config.name}", config
        Promise.resolve()


    connect: (sonos) ->
      return new Promise (resolve) ->
        return sonos.on 'initialized', (-> return resolve(sonos))

  sonosPlugin = new SonosPlugin

  return sonosPlugin