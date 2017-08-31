module.exports = (env) ->
  Promise = env.require 'bluebird'
  path = env.require('path')
  http = env.require('http')
  nodeStatic = require('node-static')
  ttsLanguages = require('./tts-providers/languages')
  createDir = require('./helpers/create-dir')(env)
  readFileNames = require './helpers/walk-sync'
  sonosFileServer = undefined
  actionFiles = readFileNames(path.join(__dirname, 'actions'), [])
  announcers =
    player: require('./helpers/announcements/single-player')
    zone: require('./helpers/announcements/zone-players')
    all: require('./helpers/announcements/all-players')



  class SonosApi
    errAction: (action, err) => env.logger.error(err, "Sonos action #{action} error")
    registerAction: (action, handler) => @actions[action] = handler
    getLanguageList: => return (key for key, value of ttsLanguages[@tts.provider])
    getLanguage: (name) => return ttsLanguages[@tts.provider][name]
    getClipNames: => readFileNames(@fileServer.directory + '/clips/', [] )

    getAnnounce: => return @announcing
    setAnnounce: (state = false) =>
      @announcing = state
      return


    constructor: (@system, config) ->
      @fileServer = null
      @server = null
      @announcers = null
      @tts = null
      @announcing = no
      @actions = {}
      @playerDeviceActions = {}
      if config.fileServer.enable
        {@fileServer, tts} = config
        if config.tts.enable
          @tts = {}
          @tts[key] = value for key, value of tts


        @announcers = announcers
        @server = _startFileServer(@fileServer)

      for file in actionFiles
        for key, action of require("./actions/#{file}")(env, @, config)
          return if action.files and not config.fileServer.enable
          if action.execute? then @actions[key] = action.execute
          if action.action? then @playerDeviceActions[key] = action.action


    deviceCommand: (player, action, values) ->
      _checkReady(player).then =>
        cmd = @actions[action] player, values
        cmd.then(-> return Promise.resolve()).catch((err) =>
          Promise.reject()
        )


#    playClip: (player, {clipName=null, volume=null, duration=null, all=false}) ->
#      return Promise.reject("no clip provided") if clipName is null
#      if clipName not in @getClipNames()
#        return Promise.reject("Clip #{clipName} not found in folder #{@directory}")
#      volume = volume or @defaultVolume
#      path = "http://#{player.system.localEndpoint}:#{@port}/clips/#{clipName}"
#      return _announce(player, path, volume, all)
#
  _checkReady = (player) ->
    return Promise.reject("System isnt initialized yet") unless player?.system?
    return Promise.reject("player doesn't exist") if not player?
    return Promise.resolve()




  _startFileServer = ({port, directory}) ->
    createDir(directory)
    createDir(directory + '/tts/')
    createDir(directory + '/clips/')
    sonosFileServer = new nodeStatic.Server(directory)
    server = http.createServer(requestHandler)
    server.listen port, ->
      env.logger.info("Sonos http file server listening on port #{port}")
    server.on 'error', ->
      if err.code and err.code is 'EADDRINUSE'
        env.logger.error "Port #{port} seems to be in use already."
      else
        env.logger.error err
      server = null
    return server

  requestHandler = (req, res) ->
    req.addListener 'end', ->
      sonosFileServer.serve req, res, (err) ->
        if not err
          return
        urlPath = req.url.split('/')
        if urlPath[0] not in ['tts', 'clips']
          res.end()
    .resume()





  return SonosApi