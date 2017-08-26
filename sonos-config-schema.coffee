path = require 'path'
defaultVolume = 40
module.exports =
  description:  "Sonos Plugin Config Options - Only required if hostFiles is true"
  type: "object"
  properties:
    fileServer:
      description: "File Server Properties"
      type: "object"
      default:
        enabled: no
        port: 3541
        webroot: path.join(__dirname, '../../sonos')
      properties:
        enabled:
          description: "Enable http file server to server to play clips and tts"
          type: "boolean"
        port:
          description:  "Port on which the the file hosting server should listen.  Default is 3541"
          type: "number"
        webroot:
          description: "Directory from which clips and tts files will be served"
          type: "string"
    tts:
      description: "Text-to-Speech Settings"
      type: "object"
      default:
        provider: "google"
        language: "en"
        defaultVolume: defaultVolume
        voiceRss: null
      properties:
        provider:
          description:  "TTS engine to use.  If not selected, will use english"
          type: "string"
          enum: ["google", "voiceRss"]
        defaultVolume:
          description: "Default volume at which clips and tts will be played"
          type: "number"
        language:
          description: "Default language to be used when playing tts"
          type: "string"
        voiceRss:
          description: "If tts provider is voiceRss, the api key to be used."
          type: "string"
      clips:
        description: "Clip Playback Settings"
        type: "object"
        default:
          defaultVolume: defaultVolume
        properties:
          defaultVolume:
            description: "Default language to be used when playing tts"
            type: "string"