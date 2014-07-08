Mincer = require('mincer')
Fs = require('node-fs')
Path = require('path')

isAbsolutePath = (path) ->
  if !path.length
    return false

  path[0] == '/'

createSprockets = (config) ->
  tmpPath = process.cwd() + "/tmp/sprockets-mincer/"

  environment = new Mincer.Environment()

  for path in config.sprocketsPath
    if isAbsolutePath(path)
      environment.appendPath(path)
    else
      environment.appendPath(config.basePath + "/" + path)

  for bundle in config.sprocketsBundles
    asset = environment.findAsset bundle

    # write to file
    tmpFile = Path.join(tmpPath, asset.logicalPath)
    tmpFile = tmpFile.replace(/\.js\.coffee$/, '.js')
    tmpFile = tmpFile.replace(/\.coffee$/, '.js')

    unless Fs.existsSync Path.dirname(tmpFile)
      # Recursively create the dir with node-fs
      Fs.mkdirSync(Path.dirname(tmpFile), 0o777, true)

    Fs.writeFileSync tmpFile, asset.toString()

    config.files.push
      included: true
      served: true
      watched: config.autoWatch
      pattern: tmpFile

createSprockets.$inject = ['config']

module.exports =
  'framework:sprockets-mincer': ['factory', createSprockets]