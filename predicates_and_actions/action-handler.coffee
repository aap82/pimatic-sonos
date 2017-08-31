module.exports = (env) ->
  _ = env.require('lodash')
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class SonosPlayerActionHandler extends env.actions.ActionHandler
    constructor: (@action, @api, @device, @values) ->
      super()

    executeAction: (simulate) =>
      if simulate
        return Promise.resolve(__("would do one of many things"))
      else
        _action = switch @action
          when 'say' then @api.say(@device.player, @values)
          when 'playClip' then @api.playClip(@device.player, @values)
          else
            Promise.reject("unknown action")

        _action.then(=> return Promise.resolve(__("done")))



  return SonosPlayerActionHandler