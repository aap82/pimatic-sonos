module.exports = (env) ->
  _ = env.require('lodash')
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher
  SonosPlayerActionHandler = require('./action-handler')(env)


  class SonosFileActionProvider extends env.actions.ActionProvider
    constructor: (@framework, @api, @config) ->
      super()

    parseAction: (input, context) =>
      return null unless @config.fileServer.enabled

      sonosPlayers = _(@framework.deviceManager.devices).values().filter(
        (device) =>
          device.config.class is 'SonosPlayer'
      ).value()


      duration = {}
      match = null
      device = null
      action = null
      text = null
      volume = @config.fileServer.defaultVolume
      clipName = null
      language = @api.defaultLanguage
      all = false


      m = M(input, context).or [
        ((m) => m.match('say ').matchString( (m, t) -> action = 'say'; text = t))
        ((m) => m.match(['play clip ', 'play file ']).match(@api.getClipNames(), (m, c) -> action = 'playClip'; clipName = c))
      ]


      if action is 'say'
        m.match(' in language ', optional: yes)
        .match @api.getLanguageList(), (_next, l) ->
          language = l
          m = _next


      if action is 'playClip'
        m.match(' for a period of ', optional: yes)
        .matchNumber (next, t) ->
          duration.time = t
          next.match([' seconds ', ' minutes '], (_next, u) ->
            duration.units = if u is ' seconds ' then 's' else 'm'
            m = _next
          )

      m.match(' at volume of ', optional: yes).matchNumber (next, v) =>
        unless 0 < v < 100
          throw new Error("volume must be between 0-100")
        volume = v
        m = next.match('% ')


      m = m.match(' on player ').matchDevice(sonosPlayers, (m , d) -> device = d)

      m = m.or [
        (m) -> m.match(' only', (-> all = false))
        (m) -> m.match(' and other players in zone', (-> all = true))
      ]


      match = m.getFullMatch()
      if match?
        assert device?
        assert typeof match is "string"
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new SonosPlayerActionHandler(
            action
            @api,
            device,
            {
              clipName,
              text,
              volume,
              language,
              duration
              all
            }
          )
        }
      else
        return null

  return SonosFileActionProvider