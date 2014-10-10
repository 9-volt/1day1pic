"use strict";

module.exports = {
  up: function(migration, DataTypes, done) {
    migration.addColumn(
      'Users',
      'email',
      {
        type: DataTypes.STRING
      , allowNull: false
      }
    )

    migration.addColumn(
      'Users',
      'password',
      {
        type: DataTypes.STRING
      , allowNull: false
      }
    )

    done();
  },

  down: function(migration, DataTypes, done) {
    migration.removeColumn('Users', 'email')
    migration.removeColumn('Users', 'password')
    done();
  }
};
