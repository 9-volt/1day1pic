############
# Requires
############
gulp = require('gulp')
config = require('./config')
# Utils
gutil = require('gulp-util')
plumber = require('gulp-plumber')
sourcemaps = require('gulp-sourcemaps')
livereload = require('gulp-livereload')
del = require('del')
# Styles
stylus = require('gulp-stylus')
nib = require('nib')
csso = require('gulp-csso')
# JS
coffee = require('gulp-coffee')
uglify = require('gulp-uglify')
# Server
nodemon = require('gulp-nodemon')

############
# Environment
############
APP_ENV = 'development'
if process.env?.APP_ENV? and process.env.APP_ENV in ['development', 'test', 'production'] then APP_ENV = process.env.APP_ENV
process.env.APP_ENV = APP_ENV # Submit environment if it was not provided on running

############
# Child tasks
############
gulp.task 'development-server', ()->
  nodemon({ script: 'server/server.coffee', ext: 'coffee', watch: 'server'})
    .on('change', [])
    .on 'restart', ()->
      console.log 'nodemon restarted!'

gulp.task 'development-style', ()->
  # Stylesheet
  gulp.src('./app/css/style.styl')
    .pipe(plumber())
    .pipe(stylus({use: [nib()], linenos: true, 'include css': true, url: {name: 'url', limit: 10000, paths: [__dirname + '/public/images']}}).on('error', gutil.log))
    .pipe(gulp.dest('./public/css'))
    .pipe(livereload({auto: false}))

gulp.task 'development-script', ()->
  # Scripts

  # Copy coffee files to view source in Chrome
  gulp.src('./app/js/**/*.coffee')
    .pipe(gulp.dest('./public/js'))

  # Build sources
  gulp.src('./app/js/*.coffee')
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(coffee({bare: true, join: true}).on('error', gutil.log))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('./public/js'))
    .pipe(livereload({auto: false}))

gulp.task 'development-watch', ()->
  livereload.listen()

  # Watch style changes
  watcher_style = gulp.watch('./app/css/**/*.styl', ['development-style'])
  watcher_style.on 'changed', (e)->
    console.log e.type + '-' + e.path

  # Watch script changes
  watcher_script = gulp.watch ['./app/js/**/*.coffee'], ['development-script']
  watcher_script.on 'changed', (e)->
    console.log(e.type + '-' + e.path)

gulp.task 'build-clean', (cb)->
  del ['./public/js/**/*.coffee'], cb


gulp.task 'build-style', ->
  gulp.src('./app/css/style.styl')
    .pipe(stylus({use: [nib()], 'include css': true, url: {name: 'url', limit: 10000, paths: [__dirname + '/public/images']}}))
    .pipe(csso(false))
    .pipe(gulp.dest('./public/css'))

gulp.task 'build-script', ->
  # Scripts
  gulp.src('./app/js/**/*.coffee')
    .pipe(coffee({bare: true, join: true, 'include css': true}).on('error', gutil.log))
    .pipe(uglify())
    .pipe(gulp.dest('./public/js'))

############
# Main tasks
############
gulp.task 'default', ['dev']
gulp.task 'dev', ['development-style', 'development-script', 'development-watch', 'development-server']
gulp.task 'build', ['build-clean', 'build-style', 'build-script']
