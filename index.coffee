Mincer = require('mincer')
Fs = require('fs')
Path = require('path')

# _eval = require 'eval'
# jQuery = require 'jquery'

# Backbone = require 'backbone'
# Backbone.setDomLibrary jQuery

# assetRoot = "#{__dirname}/assets/javascripts/"
# vendorRoot = "#{__dirname}/../vendor/assets/javascripts/"
#console.log "assetRoot => #{assetRoot}"


# environment = new Mincer.Environment()
# environment.appendPath(assetRoot)
# environment.appendPath(vendorRoot)

# js = environment.findAsset("#{assetRoot}pollev_assets_node.js.coffee").toString()
# js += """
# /* Override any module.exports calls within the snocketified code (I'm looking at you XDate). */
# module.exports = PollEv;
# """

# #console.log "js => \n#{js}"

# module.exports = _eval js, 'pollev_assets_node.js.coffee',
#   _: require('underscore')._
#   btoa: require('btoa')
#   URI: require('URIjs')
#   jQuery: jQuery
#   $: jQuery
#   Backbone: Backbone

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

    Fs.exists Path.dirname(tmpFile), (exists) ->
      if exists
        Fs.writeFile tmpFile, asset.toString()
      else
        Fs.mkdir Path.dirname(tmpFile), ->
          Fs.writeFile tmpFile, asset.toString()

    config.files.unshift
      included: true
      served: true
      watched: config.autoWatch
      pattern: tmpFile

createSprockets.$inject = ['config']

module.exports =
  'framework:sprockets-mincer': ['factory', createSprockets]