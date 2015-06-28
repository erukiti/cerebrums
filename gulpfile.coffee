gulp = require 'gulp'
coffee = require 'gulp-coffee'
espower = require 'gulp-espower'
mocha = require 'gulp-mocha'
sourcemaps = require 'gulp-sourcemaps'

gulp.task 'test', ['test:exec']

gulp.task 'test:make', [], ->
  gulp.src(['test/*.coffee'])
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe espower()
    .pipe sourcemaps.write()
    .pipe gulp.dest('espowered')

gulp.task 'test:exec', ['test:make'], ->
  gulp.src(['espowered/*.js'])
    .pipe mocha()
