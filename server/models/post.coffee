moment = require('moment')

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
        Post.find({where: {date: {lt: post.date}, available_pictures: 2}, order: [['date', 'DESC']]})
          .error (error)->
            cb error
          .then (post)->
            cb null, post

      getNextPost: (post, cb)->
        Post.find({where: {date: {gt: post.date}, available_pictures: 2}, order: [['date', 'ASC']]})
          .error (error)->
            cb error
          .then (post)->
            cb null, post

      getOrCreateByDate: (momentDate, cb)->
        momentDayStart = moment(momentDate).hour(0).minute(0).second(0)

        today = moment(momentDayStart).toDate()
        tomorrow = moment(momentDayStart).add(1, 'd').toDate()

        Post.find({where: {date: {between: [today, tomorrow]}}})
          .error (error)->
            cb(error, null)
          .then (post)->
            if post
              cb(null, post)
            else
              Post.create
                date: today
                title: ''
              .error (err)->
                cb(err, null)
              .success (post)->
                cb(null, post)
