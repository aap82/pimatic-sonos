module.exports = (env) ->
  Promise = env.require 'bluebird'

  crypto = require("crypto")
  fs = require("fs")
  path = require("path")
  http = require('http')


  voiceRss = ({tts, fileServer}, phrase, language) ->
    if tts.voiceRss is ''
      return Promise.reject("voiceRss api key not provided")
    language = "en-gb"
    ttsRequestUrl = "http://api.voicerss.org/?key=#{tts.voiceRss}&f=22khz_16bit_mono&hl=#{language}&src=#{encodeURIComponent(phrase)}"
    phraseHash = crypto.createHash("sha1").update(phrase).digest("hex")
    fileName = "voiceRss-#{phraseHash}-#{language}.mp3"
    filePath = path.resolve(fileServer.webroot, "tts", fileName)
    expectedUri = "/tts/#{fileName}"
    try
      fs.accessSync filePath, fs.R_OK
      return Promise.resolve(expectedUri)
    catch err
      console.log "announce file for phrase #{phrase} does not seem to exist, downloading"

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
#
#    return new Promise (resolve, reject) =>
#      options =
#
#
#      .then (response) =>
#        res = response
#        return res.text()
#      .then (txt) =>
#        if txt.substr(0,5) is "ERROR"
#          return Promise.reject(txt)
#      .then (p) =>
#        file = fs.createWriteStream(filePath)
#        console.log p
#        console.log 'creating voiceRss'
#
#        res.body.pipe file
#        console.log file
#        file.on "finish", =>
#          file.end()
#          console.log 'finish'
#          Promise.resolve(expectedUri)
#


  return voiceRss

