Mincer = require('mincer')
Fs = require('node-fs')
Path = require('path')
Chokidar = require('chokidar')
Shell = require('shelljs')
_ = require('underscore')
CheckDependencies = require('check-dependencies')

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
writeFiles = (config, bundles, sprockets, tmpPath, initial = true) ->
  writtenFiles = {}

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
    if initial or fileConfig.watched
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

        fullPath = Path.join(config.basePath, fileConfig.bundle)
        writtenFiles[fullPath] = fileConfig
      else
        console.log "Couldn't find asset: #{fileConfig.bundle}"

  writtenFiles

# Watch path for changes and write out all the bundles to tmp dir
watchForChanges = (config, sprockets, tmpPath) ->
  for path in config.sprocketsPaths
    if config.autoWatch
      Chokidar.watch(path, persistent: true)
        .on 'change', ->
          writeFiles(config, config.sprocketsBundles, sprockets, tmpPath, false)

createSprockets = (config) ->
  sprockets = new Mincer.Environment()

  tmpPath = process.cwd() + "/tmp/sprockets-mincer/"

  # Add additional mincer engines
  for extension, engine_path of config.mincerEngines
    unless isAbsolutePath(engine_path)
      engine_path = Path.join(config.basePath, engine_path)

    engine = require(engine_path)
    sprockets.registerEngine extension, engine
  
  # Add the rubygem paths
  for gem, sprocketsPaths of config.rubygems
    {code, stdout} = Shell.exec "bundle info --path #{gem}", silent: true
    if code == 0
      gemPath = stdout.trim()

      if Shell.test '-f', "#{gemPath}/package.json"
        CheckDependencies.sync({
          packageDir: gemPath,
          install: true
        })

      for path in sprocketsPaths
        console.log "Appending rubygem path: #{gemPath}/#{path}"
        config.sprocketsPaths.push "#{gemPath}/#{path}"

  # Set up the sprockets environment
  for path in config.sprocketsPaths
    unless isAbsolutePath(path)
      path = config.basePath + "/" + path

    # Add the path to the sprockets environment
    sprockets.appendPath(path)

  # Register helpers if any
  for helperName, helperValue of config.sprocketsHelpers
    sprockets.registerHelper helperName, helperValue

  # Write out the bundle files to the tmp directory
  # Also, preserve the order of the bundles in the config file
  config.sprocketsBundles = writeFiles(config, config.sprocketsBundles, sprockets, tmpPath)

  # Replace the file config
  config.files.forEach (obj) ->
    if config.sprocketsBundles[obj.pattern]
      _.extend obj, config.sprocketsBundles[obj.pattern]

  # Watch the sprockets paths for file changes
  unless config.singleRun
    watchForChanges(config, sprockets, tmpPath)

createSprockets.$inject = ['config']

module.exports =
  'framework:sprockets-mincer': ['factory', createSprockets]
