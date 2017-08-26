module.exports = (env) ->
  _ = env.require('lodash')
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher
  walkSync = (dir, fileList) ->
    fs = require('fs')
    files = fs.readdirSync(dir)
    fileList = fileList or []
    files.forEach (file) ->
      if fs.statSync(dir + '/' + file).isDirectory()
        fileList = walkSync(dir + file + '/', fileList)
      else
        fileList.push file
      return
    fileList


  class SonosPlayerClipActionHandler extends env.actions.ActionHandler
    constructor: (@api, @device, @values) ->
      super()

    executeAction: (simulate) =>
      if simulate
        return Promise.resolve(__("would say #{@values.text}"))
      else
        @api.playClip(@device.player, @values)
          .then(=> return Promise.resolve(__("done")))


  class SonosPlayerClipActionProvider extends env.actions.ActionProvider
    constructor: (@framework, @api, @config) ->
      super()

    parseAction: (input, context) =>
      sonosPlayers = _(@framework.deviceManager.devices).values().filter(
        (device) =>
          device.config.class is 'SonosPlayer'
      ).value()
      console.log sonosPlayers
      return unless sonosPlayers.length > 0
      clips = walkSync(@config.fileServer.webroot + '/clips/', [] )
      return unless clips.length > 0
      match = null
      device = null
      clipName = null
      volume = @config.tts.defaultVolume
      all = false


      m = M(input, context).match('play clip ').match(clips, (m, c) -> clipName = c)
      m = m.match(' on ').matchDevice(sonosPlayers, (m , d) -> device = d)
      m = m.or [
        (m) -> m.match(' player only ', (-> all = false))
        (m) -> m.match(' zone ', (-> all = true))
      ]
      m.match('at ', optional: yes).matchNumber (next, v) =>
        volume = v
        m = next.match('% volume')

      match = m.getFullMatch()


      if match?
        assert device?
        assert typeof match is "string"
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new SonosPlayerClipActionHandler(
            @api,
            device,
            {clipName, volume, all}
          )
        }
      else
        return null

  return SonosPlayerClipActionProvider