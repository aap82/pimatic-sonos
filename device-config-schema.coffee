module.exports =
  title: "pimatic-sonos device config schemas"
  SonosPlayer:
    title: "Sonos Player"
    type: "object"
    properties:
      uuid:
        description: "Unique id of the player"
        type: "string"
      defaultVolume:
        description: "Volume at which tts or files will play, if not specified in request.  Defaults to defaultVolume defined in defined."
        type: "number"
        required: no
