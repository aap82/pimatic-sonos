isRadioOrLineIn = (uri) ->
  return uri.startsWith('x-sonosapi-stream:') or
    uri.startsWith('x-sonosapi-radio:') or
    uri.startsWith('pndrradio:') or
    uri.startsWith('x-sonosapi-hls:') or
    uri.startsWith('x-rincon-stream:') or
    uri.startsWith('x-sonos-htastream:') or
    uri.startsWith('x-sonosprog-http:') or
    uri.startsWith('x-rincon-mp3radio:')



module.exports = isRadioOrLineIn