"use strict";

module.exports = {
  up: function(migration, DataTypes, done) {
    migration.addColumn(
      'Posts',
      'title',
      DataTypes.STRING
    )

    done();
  },

  down: function(migration, DataTypes, done) {
    migration.removeColumn('Posts', 'title')

    done();
  }
};
