db = require('../models')
dateHelper = require('../helpers/date')

postController =
  getIndex: (req, res)->
    # Get last available post with 2 pictures
    db.Post.find({where: {available_pictures: 2}, order: [['date', 'DESC']], include: [db.Picture]})
      .error (error)->
        res.send('404')
      .then (post)->
        postController.renderPost req, res, post

  getDate: (req, res)->
    utcDayStart = dateHelper.getUtcDayStart(dateHelper.parseUrlFormat(req.param('date')))

    # Get the post from date specified in params
    db.Post.find({where: {date: utcDayStart}, include: [db.Picture]})
      .error (error)->
        res.send('404')
      .then (post)=>
        postController.renderPost req, res, post

  renderPost: (req, res, post)->
    if not post?
      res.send('404')
    else
      # Pictures should be ordered randomly
      seed = Math.floor(Math.random() * 999)

      # Check if there are older and newer pictures
      db.Post.getPreviousPost post, (err, previousPost)->
        db.Post.getNextPost post, (err, nextPost)->

          previousPostLink = if not previousPost? then null else '/post/' + dateHelper.getUrlFormat(previousPost.date)
          nextPostLink = if not nextPost? then null else '/post/' + dateHelper.getUrlFormat(nextPost.date)

          res.render 'index',
            pageTitle: '1day1pic'
            post: post
            picture1: post.Pictures[seed % 2]
            picture2: post.Pictures[(seed + 1) % 2]
            previousPostLink: previousPostLink
            nextPostLink: nextPostLink

module.exports = postController
