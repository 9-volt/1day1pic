moment = require('moment')
Sequelize = require('sequelize')

module.exports = (sequelize, DataTypes)->
  Post = sequelize.define 'Post',
    id:
      type: DataTypes.INTEGER
      autoIncrement: true
      primaryKey: true
    date: DataTypes.DATE
    title: DataTypes.STRING
    available_pictures:
      type: DataTypes.INTEGER(4)
      defaultValue: 0
  ,
    classMethods:
      associate: (models)->
        Post.hasMany(models.Picture)

      getPreviousPost: (post, cb)->
        Post.find
          where:
            Sequelize.or(
              available_pictures: 2
              date: {lt: post.date}
            ,
              Sequelize.and
                available_pictures: 1
              ,
                Sequelize.and
                  date: {lt: post.date}
                ,
                  date: {lt: new Date(Date.now() - 86400000*3)}
            )
          order: [['date', 'DESC']]
        .then (post)->
          cb null, post
        .catch (error)->
          cb error

      getNextPost: (post, cb)->
        Post.find
          where:
            Sequelize.or(
              available_pictures: 2
              date: {gt: post.date}
            ,
              Sequelize.and
                available_pictures: 1
              ,
                Sequelize.and
                  date: {gt: post.date}
                ,
                  date: {lt: new Date(Date.now() - 86400000*3)}
            )
          order: [['date', 'ASC']]
        .then (post)->
          cb null, post
        .catch (error)->
          cb error

      getOrCreateByDate: (date, cb)->
        Post.find({where: {date: date}})
          .then (post)->
            if post
              cb(null, post)
            else
              Post.create
                date: date
                title: ''
              .then (post)->
                cb(null, post)
              .catch (err)->
                cb(err, null)
          .catch (error)->
            cb(error, null)
