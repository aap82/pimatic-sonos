module.exports = (env, {ttsPath, config}) ->
  Promise = env.require 'bluebird'

  crypto = require("crypto")
  fs = require("fs")
  path = require("path")
  http = require('http')
  languages = require('./languages').voiceRss
  defaultLanguageKey = languages[config.language]
  apiKey = config.key
  voiceRss = (phrase, lang=null) ->
    if apiKey is ''
      return Promise.reject("voiceRss api key not provided")
    language = languages[lang] or defaultLanguageKey

    ttsRequestUrl = "http://api.voicerss.org/?key=#{apiKey}&f=22khz_16bit_mono&hl=#{language}&src=#{encodeURIComponent(phrase)}"
    phraseHash = crypto.createHash("sha1").update(phrase).digest("hex")
    fileName = "voiceRss-#{phraseHash}-#{language}.mp3"
    filePath = path.resolve(ttsPath, fileName)
    expectedUri = "/tts/#{fileName}"
    try
      fs.accessSync filePath, fs.R_OK
      return Promise.resolve(expectedUri)
    catch err
      console.log "VoiceRSS: announce file for phrase #{phrase} does not seem to exist, downloading"

    new Promise((resolve, reject) ->
      file = fs.createWriteStream(filePath)
      http.get ttsRequestUrl, (response) =>
        if response.statusCode < 300 and response.statusCode >= 200
          response.pipe file
          file.on 'finish', ->
            file.end()
            stats = fs.statSync(filePath)
            if stats.size < 2400
              fs.unlink filePath
              return reject("VoiceRss download failed")
            return resolve expectedUri

        else
          return
      .on 'error', (err) ->
        console.log 'err'
        console.log err
        fs.unlink dest
        resolve('voiceRss')
        return
      return
    )


  voiceRss

