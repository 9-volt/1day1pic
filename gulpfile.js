/*
  Keep this file because gulp does not support running directly from CoffeeScript
 */

require('coffee-script/register');
var gutil = require('gulp-util');

// Specify, where is your Gulp config in CoffeeScript placed.
var gulpfile = 'gulpfile.coffee';
gutil.log('Using file', gutil.colors.magenta(gulpfile));

// Execute CoffeeScript config.
require('./' + gulpfile);
