'use strict';

module.exports = {
  up: function (migration, DataTypes, done) {
    migration.addColumn(
      'Pictures',
      'posted_to_fb',
      {
        type: DataTypes.BOOLEAN
      , default: false
      }
    );

    done();
  },

  down: function (migration, DataTypes, done) {
    migration.removeColumn('Pictures', 'posted_to_fb');

    done();
  }
};
