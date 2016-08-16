# karma-sprockets-mincer

Serve assets developed for Sprockets with Mincer

## Installation

Add `karma-sprockets-mincer` as a devDependency in your `package.json`.
```json
{
  "devDependencies": {
    "karma": "",
    "karma-sprockets-mincer": ""
  }
}
```

or

```bash
npm install karma-sprockets-mincer --save-dev
```

## Configuration

Add the plugin to your config file.

```coffeescript
  plugins: [
    'karma-phantomjs-launcher'
    [...]
    'karma-sprockets-mincer'
  ]
```

Then add `sprockets-mincer` to the top of the frameworks list (order is important).

```coffeescript
frameworks: [
  "sprockets-mincer"
  "jasmine"
]
```

Next, configure the paths that the Sprockets (Mincer) environment should know about.
```coffeescript
sprocketsPaths: [
  'app/assets/javascripts'
  'lib/assets/javascripts'
  'vendor/assets/javascripts'
]
```

Then, configure the js bundle files that Sprockets should generate. These files will be regenerated whenever a sprockets environment file changes.
```coffeescript
sprocketsBundles: [
  'application.coffee'
]
```

Be sure to also add files listed in `sprocketsBundles` to `config.files` in the correct place. `sprockets-mincer` will replace the `pattern` in `config.files` with the one that is compiled.

```
files: [
  ...
  'application.coffee' # this pattern will be replaced automatically
  ...
]
```

### Helpers

You can add helpers that the assets might be using:

```coffeescript
sprocketsHelpers:
  asset_path: (fileName) -> return "assets/#{fileName}"
```

### RubyGems

If you are using this in a Ruby/Rails project, you can add the rubygem paths as well:

```coffeescript
# "gem-name": ["array of", "sprockets paths"]
rubygems: {
  "rails-widget": ["lib/assets/javascripts", "vendor/assets/javascripts"]
  "jquery-rails": ["vendor/assets/javascripts"]
}
```

This will run grab the path of the bundled gem by running `bundle show` and add them with the specified paths to Sprockets/Mincer.

### Additional Mincer engines

The path to engine file can be both absolute or relative to `basePath`.

```coffeescript
# "extension": "path-to-engine-definition-file.js"
mincerEngines: {
  ".hbs": "./lib/handlebarsjst.js",
  ".xxx": "/opt/mincer-ext/engine.js"
}
```

### Additional Mincer processors

It is also possible to pass additional [preprocessors] and [postprocessors]. As for engines,
the path to the processor file can be both absolute or relative to `basePath`.

```coffeescript
# "mimeType":  [ "path-to-processor.js", "path-to-another-processor.js" ]
mincerPreprocessors: {
  "text/css": [ "./stylesheets/frobnicate.js", "./stylesheets/decorate.js" ],
  "application/javascript": [ "/opt/instrumentation/instrumenter.js" ]
},

mincerPostprocessors: {
  "application/javascript": [ "/opt/instrumentation/report.js" ]
}
```

[preprocessors]: http://nodeca.github.io/mincer/#Processing.prototype.registerPreProcessor
[postprocessors]: http://nodeca.github.io/mincer/#Processing.prototype.registerPostProcessor
