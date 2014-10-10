module.exports = (sequelize, DataTypes)->
  Post = sequelize.define 'Post',
    id:
      type: DataTypes.INTEGER
      autoIncrement: true
      primaryKey: true
    date: DataTypes.DATE
    available_pictures:
      type: DataTypes.INTEGER(4)
      defaultValue: 0
  ,
    classMethods:
      associate: (models)->
        Post.hasMany(models.Picture)
