module.exports = (sequelize, DataTypes)->
  Picture = sequelize.define 'Picture',
    id:
      type: DataTypes.INTEGER
      autoIncrement: true
      primaryKey: true
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
    instanceMethods:
      customSetPost: (post, cb)->
        this.setPost(post)
          .error (err)->
            cb(err)
          .success ->
            post.increment({'available_pictures': 1})
              .error (err)->
                cb(err)
              .success ->
                cb()
