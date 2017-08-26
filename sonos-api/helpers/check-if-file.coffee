module.exports = (file) ->
  return new Promise (resolve, reject) ->
    fsStat(file)
    .then (stats) ->
      resolve(stats.isFile())
    .catch (err) ->
      if err.code is 'ENOENT'
        resolve(false)
      else
        reject(err)

