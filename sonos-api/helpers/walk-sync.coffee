module.exports = ->
  walkSync = (dir, fileList) ->
    fs = require('fs')
    files = fs.readdirSync(dir)
    fileList = fileList or []
    files.forEach (file) ->
      if fs.statSync(dir + '/' + file).isDirectory()
        fileList = walkSync(dir + file + '/', fileList)
      else
        fileList.push file
      return
    fileList

  walkSync