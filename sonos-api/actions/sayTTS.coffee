module.exports = (env, api) ->
  {tts, fileServer} =api
  Promise = env.require 'bluebird'
  path = require 'path'

  port = fileServer.port
  ttsProvider = tts.provider
  ttsPath = path.join fileServer.directory, 'tts'
  ttsProviders =
    google: require('../tts-providers/google')(env, {ttsPath, config: tts.google})
    voiceRss: require('../tts-providers/voiceRss')(env, {ttsPath, config: tts.voiceRss})

  getTrackURL = (player, path) -> return  "http://#{player.system.localEndpoint}:#{port}#{path}"
  getVolume = (v) ->
    switch
      when isNaN(v) then return defaultVolume
      when 0 < v <=100 then return v
      else return defaultVolume


  tryTTSProvider = (provider, phrase, language) =>
    ttsProviders[provider](phrase, language).then (filePath) =>
      console.log filePath
      return filePath
    .catch (err) =>
      if ttsProvider is 'google'
        return Promise.reject(err)
      else
        return provider

  tryDownloadTTS = (phrase, language) ->
    tryTTSProvider(ttsProvider, phrase, language).then (result) =>
      if result is ttsProvider
        tryProvider('google', phrase, language)
      else
        return result

  sayAction = (announcer, player, {text, volume = null, language=null}, group) =>
    return Promise.reject("Already announcing") if api.getAnnounce()
    tryDownloadTTS(text, language).then (path) =>
        volume = volume or player.config.defaultVolume
        announcer(api, player, getTrackURL(player, path), getVolume(parseInt(volume,10)), group)
      .catch (err) =>
        return Promise.reject("Error trying to play tts-file: #{err}")

  sayPlayer = (player, options) => sayAction(api.announcers.player, player, options)

  sayZone = (player, options) =>
    console.log player.config.defaultVolume
    group = player.system.zones.find((zone) => zone.coordinator.uuid is player.coordinator.uuid)

#        if group.members.length is 0
#          announce.player(player, getTrackURL(player, path), volume)
#        else
    sayAction(api.announcers.zone, player, options, group)






  return {
    say:
      files: yes
      execute: sayZone
      action:
        description: "Say something"
        params:
          text:
            type: "string"
          volume:
            optional: yes
            type: "string"
          language:
            optional: yes
            type: "string"
    sayZone:
      files: yes
      execute: sayZone
      action:
        description: "Say something"
        params:
          text:
            type: "string"
          volume:
            optional: yes
            type: "string"
          language:
            optional: yes
            type: "string"

  }





