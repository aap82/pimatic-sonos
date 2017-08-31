fs = require('fs')
JSON5 = require('json5')

tryLoadJson = (path) ->
  try
    fileContent = fs.readFileSync(path)
    parsedContent = JSON5.parse(fileContent)
    return parsedContent
  catch e
    if e.code == 'ENOENT'
      console.log("Could not find file #{path}")
    else
      console.log("Could not read file #{path}, ignoring.", e)
  {}


module.exports = tryLoadJson