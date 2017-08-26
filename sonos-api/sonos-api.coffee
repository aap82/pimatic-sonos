module.exports = (env) ->
  Promise = env.require 'bluebird'
  path = env.require('path')
  http = env.require('http')
  nodeStatic = require('node-static')
  createDir = require('./helpers/create-dir')(env)
  requireDir = require('./helpers/require-dir')

  singlePlayerAnnouncement = require('./helpers/single-player-announcement')
  allPlayerAnnouncement = require('./helpers/all-player-announcement')

  ttsHandler = require('./tts-providers/tts')(env)
  sonosFileServer = undefined

  class SonosApi
    registerAction: (action, handler) => @actions[action] = handler

    constructor: (@config) ->
      {@fileServer, @tts} = @config
      @server = null
      @actions = {}
      if @fileServer.enabled
        {@port, @webroot} = @fileServer
        @server = _startFileServer(@fileServer)
      requireDir path.join(__dirname, './actions'), (registerAction) => registerAction this

    command: (player, action, values) ->
      if action in ['say', 'playClip']
        if not @fileServer.enabled then return throw new Error("Cannot use say or playClip commands without enabling file hosting")
        else if not @server? then return throw new Error("Http file server not running.  Please check logs.")
        else switch action
          when 'say' then return @say(player, values)
          else return Promise.resolve()
      return Promise.reject("player doesn't exist") if not player?
      return Promise.reject("action #{action} not found") if !@actions[action]
      values.level = values.level.replace(' ', '+') if action in ["volume","groupVolume"]
      cmd = @actions[action] player, values
      cmd.then(-> return Promise.resolve())


    fileCommands: (player, action, values) ->
      return @say(player, values) if action is 'say'
      Promise.resolve()

    say: (player, {text = null, volume = null, language=null,all=false }) ->
      return Promise.reject("System isnt initialized yet") unless player?.system?
      return Promise.reject("No text provided to say") unless text?
      announceVolume = volume or @tts.defaultVolume
      language = language or @tts.language
      basePath = "http://#{player.system.localEndpoint}:#{@port}"
      ttsHandler(@config, text, language).then (path) =>
          finalPath = basePath + path
          return allPlayerAnnouncement player, finalPath, announcclipNameeVolume if all
          return singlePlayerAnnouncement player, finalPath, announceVolume
        .catch (err) =>
          Promise.reject(err)



    playClip: (player, {clipName=null, volume=null, all=false}) ->
      return Promise.reject("fileName not provided")  unless clipName?
      path = "http://#{player.system.localEndpoint}:#{@port}/clips/#{clipName}"
      announceVolume = "#{volume or @tts.defaultVolume}"
      return allPlayerAnnouncement player, path, announceVolume if all
      return singlePlayerAnnouncement player, path, announceVolume




  _startFileServer = ({webroot, port}) ->
    createDir(webroot)
    createDir(webroot + '/tts/')
    createDir(webroot + '/clips/')
    sonosFileServer = new nodeStatic.Server(webroot)
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

