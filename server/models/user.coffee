module.exports = (sequelize, DataTypes)->
  User = sequelize.define 'User',
    name:
      type: DataTypes.STRING(32)
      defaultValue: 'No name'
  ,
    classMethods:
      associate: (models)->
        User.hasMany(models.Picture)
