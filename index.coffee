Mincer = require('mincer')
Fs = require('node-fs')
Path = require('path')
Chokidar = require('chokidar')
Shell = require('shelljs')

isAbsolutePath = (path) ->
  if !path.length
    return false

  path[0] == '/'

# Write all the files out to the tmp directory
writeFiles = (bundles, sprockets, tmpPath) ->
  writtenFiles = []

  for bundle in bundles
    asset = sprockets.findAsset bundle

    # write to file
    tmpFile = Path.join(tmpPath, asset.logicalPath)
    tmpFile = tmpFile.replace(/\.js\.coffee$/, '.js')
    tmpFile = tmpFile.replace(/\.coffee$/, '.js')

    unless Fs.existsSync Path.dirname(tmpFile)
      # Recursively create the dir with node-fs
      Fs.mkdirSync(Path.dirname(tmpFile), 0o777, true)

    Fs.writeFileSync tmpFile, asset.toString()
    writtenFiles.push tmpFile

  writtenFiles

# Watch path for changes and write out all the bundles to tmp dir
watchForChanges = (config, sprockets, tmpPath) ->
  for path in config.sprocketsPaths
    Chokidar.watch(path, persistent: true)
      .on 'change', ->
        writeFiles(config.sprocketsBundles, sprockets, tmpPath)

createSprockets = (config) ->
  sprockets = new Mincer.Environment()

  tmpPath = process.cwd() + "/tmp/sprockets-mincer/"

  # Add the rubygem paths
  for gem, sprocketsPath of config.rubygems
    {code, output} = Shell.exec "bundle show #{gem}", silent: true
    if code == 0
      gemPath = output.trim()
      Shell.exec "cd #{gemPath}; npm install"
      console.log "Appending rubygem path: #{gemPath}/#{sprocketsPath}"
      config.sprocketsPaths.push "#{gemPath}/#{sprocketsPath}"

  # Set up the sprockets environment
  for path in config.sprocketsPaths
    unless isAbsolutePath(path)
      path = config.basePath + "/" + path

    # Add the path to the sprockets environment
    sprockets.appendPath(path)

  # Write out the bundle files to the tmp directory
  for path in writeFiles(config.sprocketsBundles, sprockets, tmpPath)
    config.files.push
      included: true
      served: true
      watched: config.autoWatch
      pattern: path

  # Watch the sprockets paths for file changes
  watchForChanges(config, sprockets, tmpPath)

createSprockets.$inject = ['config']

module.exports =
  'framework:sprockets-mincer': ['factory', createSprockets]