module.exports = (sequelize, DataTypes)->
  User = sequelize.define 'User',
    id:
      type: DataTypes.INTEGER
      autoIncrement: true
      primaryKey: true
    name:
      type: DataTypes.STRING(32)
      defaultValue: 'No name'
    email:
      type: DataTypes.STRING
      allowNull: false
    password:
      type: DataTypes.STRING
      allowNull: false
  ,
    classMethods:
      associate: (models)->
        User.hasMany(models.Picture)
