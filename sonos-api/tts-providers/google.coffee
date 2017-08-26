module.exports = (env) ->
  crypto = require("crypto")
  fs = require("fs")
  http = require("http")
  path = require("path")

  google = ({fileServer}, phrase, language) ->
    if !language
      language = "en"
    # Construct a filesystem neutral filename
    phraseHash = crypto.createHash("sha1").update(phrase).digest("hex")
    filename = "google-#{phraseHash}-#{language}.mp3"
    filePath = path.resolve(fileServer.webroot, "tts", filename)
    expectedUri = "/tts/#{filename}"
    try
      fs.accessSync filepath, fs.R_OK
      return Promise.resolve(expectedUri)
    catch err
      env.logger.debug "announce file for phrase #{phrase} does not seem to exist, downloading"

    return new Promise((resolve, reject) ->
      file = fs.createWriteStream(filePath)
      options =
        headers: "User-Agent": "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
        host: "translate.google.com"
        path: "/translate_tts?client=tw-ob&tl=" + language + "&q=" + encodeURIComponent(phrase)

      callback = (response) ->
        if response.statusCode < 300 and response.statusCode >= 200
          response.pipe file
          file.on "finish", ->
            file.end()
            stats = fs.statSync(filePath)
            if stats.size < 2400
              fs.unlink filePath
              return reject("Google TTS download failed")
            return resolve expectedUri
        else
          reject new Error("Download from google TTS failed with status #{response.statusCode}, #{response.message}")
        return

      http.request(options, callback).on("error", (err) ->
        fs.unlink dest
        reject err
        return
      ).end()
      return
    )

  google
