module.exports = (env) ->
  Promise = env.require 'bluebird'
  providers = {}
  path = require 'path'


  providers =
    google: require('./google') env
    voiceRss: require('./voiceRss') env


  tryProvider = (ttsProvider, config, phrase, language) =>
    providers[ttsProvider](config, phrase, language).then (ttsPath) =>
      return ttsPath
    .catch (err) =>
      if ttsProvider is 'google'
        return Promise.reject(err)
      else
        return ttsProvider

  tryDownloadTTS = (config, phrase, language) =>
    {provider} = config.tts
    return Promise.resolve() unless providers[provider]?
    tryProvider(provider, config, phrase, language).then (result) =>
      if result is provider
        console.log 'trying google'
        tryProvider('google', config, phrase, language)
      else
        return result






#      ttsPath = _path
#      return ttsPath
#      promise.then () =>
#        return ttsPath if ttsPath
#        provider(webroot, phrase, language).then (_path) =>
#          ttsPath = _path
#          return ttsPath
#    , Promise.resolve()


  return tryDownloadTTS