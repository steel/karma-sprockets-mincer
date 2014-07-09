# karma-sprockets-mincer

> Serve assets developed for Sprockets with Mincer

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

```json
plugins: [
  'karma-phantomjs-launcher'
  [...]
  'karma-sprockets-mincer'
]
```

Next, configure the paths that the Sprockets (Mincer) environment should know about.
```json
sprocketsPaths: [
  'app/assets/javascripts'
  'lib/assets/javascripts'
  'vendor/assets/javascripts'
]
```

Then, configure the js bundle files that Sprockets should generate. These files will be regenerated whenever a sprockets environment file changes.
```json
sprocketsBundles: [
  'application.js'
]
```
