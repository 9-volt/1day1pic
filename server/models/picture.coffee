module.exports = (sequelize, DataTypes)->
  Picture = sequelize.define 'Picture',
    id:
      type: DataTypes.INTEGER
      autoIncrement: true
      primaryKey: true
    image: DataTypes.STRING
    thumbnail: DataTypes.STRING
    title:
      type: DataTypes.STRING(255)
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
          .then ->
            post.increment({'available_pictures': 1})
              .then ->
                cb()
              .catch (err)->
                cb(err)
          .catch (err)->
            cb(err)

    hooks:
      beforeDestroy: (picture, options)->
        picture.getPost()
          .then (post)->
            if post.available_pictures is 1
              post.destroy()
            else
              post.decrement({'available_pictures': 1})
