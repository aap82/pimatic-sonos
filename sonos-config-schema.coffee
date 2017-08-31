path = require 'path'
ttsLanguages = require './sonos-api/tts-providers/languages'
defaultVolume = 40
defaultLanguage = require('./sonos-api/helpers/try-load-json')(path.join(__dirname, '../../config.json'))
  .settings?.locale or 'English (United States)'

defaultLanguages = [
  'German'
  'Dutch'
  'Spanish'
  "English (Australia)"
  "English (Great Britain)"
  "English (United States)"
]

defaultLanguage = switch defaultLanguage
  when 'de' then 'German'
  when 'nl' then 'Dutch'
  when 'es' then 'Spanish'
  else defaultLanguage

module.exports =
  title: "Sonos System Plugin Options"
  type: "object"

  properties:
    fileServer:
      description: "This will start an HTTP server that will serve custom files that can be played through Sonos"
      type: 'object'
      title: "File Server"
      default:
        enable: yes
        port: 3547
        directory: path.join(__dirname, '../../sonos')
        volume: 50
      properties:
        enable:
          type: "boolean"
        port:
          description:  "Port on which the the file hosting server should listen.  Default is 3547"
          type: "number"
        directory:
          description: "Path to the directory which will hold files to be hosted"
          type: "string"
        volume:
          description: "Default volume at which clips and tts will be played"
          type: "number"
    tts:
      type: 'object'
      description: "Text to Speech config options.  You can provide plugin with text, which will be said over Sonos Players"
      default:
        enable: no
        provider: 'google'
        language: defaultLanguage
      properties:
        enable:
          type: "boolean"
        provider:
          description:  "TTS engine to use.  If not selected, will use english"
          type: "string"
          enum: ["google", "voiceRss"]
        language:
          description: "Default language based on pimatic locale when using tts service"
          enum: defaultLanguages
          type: "string"
        google:
          description: "Google TTS Language Overide"
          type: "object"
          required: no
          properties:
            language:
              description: "Google language to be used when playing tts"
              type: "string"
              enum: (key for key, value of ttsLanguages.google)
              default: defaultLanguage
              required: no
              optional: yes
        voiceRss:
          description: "Options if using voiceRss"
          type: "object"
          required: no
          properties:
            key:
              description: "If tts provider is voiceRss, the api key to be used."
              type: "string"
              default: ''
              optional: yes
            language:
              description: "voice rss language"
              type: "string"
              enum: (key for key, value of ttsLanguages.voiceRss)
              default: defaultLanguage
              required: no
              optional: yes



