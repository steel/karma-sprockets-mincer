Mincer = require('mincer')
Fs = require('node-fs')
Path = require('path')
Chokidar = require('chokidar')
Shell = require('shelljs')
_ = require('underscore')

# Skip .erb files because Ruby <> JS
require("mincer-fileskipper") Mincer, [".erb"]

# Add hamlcoffee support
require('mincer-haml-coffee') Mincer

# HamlJS is similar to Hamlc. We'll just use Hamlcoffee handle it for now
Mincer.registerEngine '.hamljs', Mincer.HamlCoffeeEngine

isAbsolutePath = (path) ->
  if !path.length
    return false

  path[0] == '/'

# Write all the files out to the tmp directory
writeFiles = (bundles, sprockets, tmpPath) ->
  writtenFiles = []

  for bundle in bundles
    if typeof bundle == "string"
      fileConfig = bundle: bundle
    else
      fileConfig = bundle

    _.defaults fileConfig,
      bundle: fileConfig.pattern
      included: true
      served: true
      watched: true
      nocache: false

    asset = sprockets.findAsset(fileConfig.bundle)

    if asset && asset.logicalPath?
      # write to file
      tmpFile = Path.join(tmpPath, asset.logicalPath)
      tmpFile = tmpFile.replace(/\.js\.coffee$/, '.js')
      tmpFile = tmpFile.replace(/\.coffee$/, '.js')

      unless Fs.existsSync Path.dirname(tmpFile)
        # Recursively create the dir with node-fs
        Fs.mkdirSync(Path.dirname(tmpFile), 0o777, true)

      Fs.writeFileSync tmpFile, asset.toString()
      fileConfig.pattern = tmpFile
      writtenFiles.push(fileConfig)
    else
      console.log "Couldn't find asset: #{bundle}"

  writtenFiles

# Watch path for changes and write out all the bundles to tmp dir
watchForChanges = (config, sprockets, tmpPath) ->
  for path in config.sprocketsPaths
    if config.autoWatch
      Chokidar.watch(path, persistent: true)
        .on 'change', ->
          writeFiles(config.sprocketsBundles, sprockets, tmpPath)

createSprockets = (config) ->
  sprockets = new Mincer.Environment()

  tmpPath = process.cwd() + "/tmp/sprockets-mincer/"

  # Add the rubygem paths
  for gem, sprocketsPaths of config.rubygems
    {code, output} = Shell.exec "bundle show #{gem}", silent: true
    if code == 0
      gemPath = output.trim()

      if Shell.test '-f', "#{gemPath}/package.json"
        Shell.exec "cd #{gemPath}; npm install"

      for path in sprocketsPaths
        console.log "Appending rubygem path: #{gemPath}/#{path}"
        config.sprocketsPaths.push "#{gemPath}/#{path}"

  # Set up the sprockets environment
  for path in config.sprocketsPaths
    unless isAbsolutePath(path)
      path = config.basePath + "/" + path

    # Add the path to the sprockets environment
    sprockets.appendPath(path)

  # Write out the bundle files to the tmp directory
  # Also, preserve the order of the bundles in the config file
  paths = writeFiles(config.sprocketsBundles, sprockets, tmpPath)

  # put these files at the top of the files list
  config.files.unshift.apply(config.files, paths)

  # Watch the sprockets paths for file changes
  unless config.singleRun
    watchForChanges(config, sprockets, tmpPath)

createSprockets.$inject = ['config']

module.exports =
  'framework:sprockets-mincer': ['factory', createSprockets]
