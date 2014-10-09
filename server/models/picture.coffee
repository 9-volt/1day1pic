module.exports = (sequelize, DataTypes)->
  Picture = sequelize.define 'Picture',
    image: DataTypes.STRING
    thumbnail: DataTypes.STRING
    title:
      type: DataTypes.TEXT
      defaultValue: 'No title'
    location_coordinates:
      type: DataTypes.STRING
      defaultValue: '0,0'
    location: DataTypes.STRING(127)
  ,
    classMethods:
      associate: (models)->
        Picture.belongsTo(models.User)
        Picture.belongsTo(models.Post)
