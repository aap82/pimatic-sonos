module.exports = (env) ->
  fs = require('fs')

  createDirectory = (dir) ->
    if !fs.existsSync(dir)
      try
        fs.mkdirSync dir
      catch
        env.logger.warn "Could not create directory #{dir}"


  return createDirectory

