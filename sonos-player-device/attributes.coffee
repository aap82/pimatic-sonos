module.exports = 
  currentArtist:
    description: "the current playing track artist"
    type: "string"
  currentTitle:
    description: "the current playing track title"
    type: "string"
  state:
    description: "the current state of the player"
    type: "string"
  volume:
    description: "the volume of the player"
    type: "string"
  mute:
    description: "is the player currently on mute"
    type: "boolean"
  
#
#
#  currentTrack:
#      artist: '',
#      title: '',
#      album: '',
#      albumArtUri: '',
#      duration: 0,
#      uri: '',
#      type: URI_TYPE.TRACK,
#      stationName: ''
#  nextTrack: Object.freeze({
#    artist: '',
#    title: '',
#    album: '',
#    albumArtUri: '',
#    duration: 0,
#    uri: ''
#  playMode: Object.freeze({
#    repeat: REPEAT_MODE.NONE,
#    shuffle: false,
#    crossfade: false
#  playlistName: '',
#  relTime: 0,
#  stateTime: 0,
#  volume: 0,
#  mute: false,
#  trackNo: 0,
#  playbackState: 'STOPPED',
#  equalizer: {
#    bass: 0,
#    treble: 0,
#    loudness: false
#  