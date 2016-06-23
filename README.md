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

Optionally configure helpers that the assets might be using.

```coffeescript
sprocketsHelpers:
  asset_path: (fileName) -> return "assets/#{fileName}"
```

You can also add sprockets paths from RubyGems if you are using this in a Ruby/Rails project.

```coffeescript
# "gem-name": ["array of", "sprockets paths"]
rubygems: {
  "rails-widget": ["lib/assets/javascripts", "vendor/assets/javascripts"]
  "jquery-rails": ["vendor/assets/javascripts"]
}
```

This will run grab the path of the bundled gem by running `bundle show` and add them with the specified paths to Sprockets/Mincer.

If you need to use additional Mincer engines there is an option to bind extensions with externally defined engines.
The path to engine file might be defined as absolute or relative to `basePath`.

```coffeescript
# "extension": "path-to-engine-definition-file.js"
mincerEngines: {
  ".hbs": "./lib/handlebarsjst.js",
  ".xxx": "/opt/mincer-ext/engine.js"
}
```
