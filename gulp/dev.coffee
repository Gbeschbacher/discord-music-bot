browserify = require "browserify"
connect    = require "gulp-connect"
gulp       = require "gulp"
gutil      = require "gulp-util"
notify     = require "gulp-notify"
watcher = require "gulp-watch"
fn = require "gulp-fn"
path       = require "path"
source     = require "vinyl-source-stream"
timer      = require "gulp-duration"
watchify   = require "watchify"
coffeeify = require "coffeeify"
error = require "./error"

FILES = "./src/**/*.*"
IN = "./src/init.coffee"
OUT = "discord.js"

bundler = browserify(watchify.args)
bundler.transform("coffeeify")

run = ->
  module = path.resolve "./", IN
  delete require.cache[require.resolve(module)]
  require module

rebundle = ->
  bundler.bundle()
    .on "error", notify.onError error
    .pipe source OUT
    .pipe gulp.dest "./"
    .pipe timer "Total Build Time"
    .pipe notify
      title:   "Discord Music Bot!"
      message: "New Build Compiled"
    .pipe connect.reload()
    .pipe fn ->
      run()
    .on "error", notify.onError error

watch = watchify(bundler)
  .add IN
  .on "update", rebundle

gulp.task "server", ->
  connect.server
    livereload: true
    port: 4000
    root: path.resolve "./"

gulp.task "dev", ->
  rebundle()

  watcher FILES, (file) ->
    fileName = path.relative "./", file.path
    gutil.log gutil.colors.cyan(fileName), "changed"
