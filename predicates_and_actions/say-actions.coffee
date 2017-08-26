module.exports = (env) ->
  _ = env.require('lodash')
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher


  class SonosPlayerSayActionHandler extends env.actions.ActionHandler
    constructor: (@api, @device, @values) ->
      super()

    executeAction: (simulate) =>
      if simulate
        return Promise.resolve(__("would say #{@values.text}"))
      else
        @api.say(@device.player, @values)
          .then(=> return Promise.resolve(__("done")))


  class SonosPlayerSayActionProvider extends env.actions.ActionProvider
    constructor: (@framework, @api, @config) ->
      super()

    parseAction: (input, context) =>
      sonosPlayers = _(@framework.deviceManager.devices).values().filter(
        (device) => device.config.class is 'SonosPlayer'
      ).value()
      return unless sonosPlayers.length > 0

      device = null
      match = null
      text = null
      volume = @config.tts.defaultVolume
      language = null
      all = false

      m = M(input, context).match('say ').matchString( (m, t) -> text = t)
      m = m.match(' on ').matchDevice(sonosPlayers, (m , d) -> device = d)
      m = m.or [
        (m) -> m.match(' player only ', (-> all = false))
        (m) -> m.match(' zone ', (-> all = true))
      ]
      m.match('at ', optional: yes).matchNumber (next, v) =>
        volume = v
        m = next.match('% volume')

      m = m.optional((m) ->
        m.match('and say it in ').matchString( (m, t) -> language = t)
      )
      match = m.getFullMatch()


      if match?
        assert device?
        assert typeof match is "string"
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new SonosPlayerSayActionHandler(
            @api,
            device,
            {text, volume, language, all}
          )
        }
      else
        return null

  return SonosPlayerSayActionProvider