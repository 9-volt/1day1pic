db = require('../models')
moment = require 'moment'

postController =
  getIndex: (req, res)->
    # Get last available post with 2 pictures
    db.Post.find({where: {available_pictures: 2}, order: [['date', 'DESC']], include: [db.Picture]})
      .error (error)->
        res.send('404')
      .then (post)->
        postController.renderPost req, res, post

  getDate: (req, res)->
    paramDate = moment(req.param('date'), 'DDMMMYYYY')
    today = moment(paramDate).toDate()
    tomorrow = moment(paramDate).add(1, 'd').toDate()

    # Get the post from date specified in params
    db.Post.find({where: {date: {between: [today, tomorrow]}}, include: [db.Picture]})
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

      res.render 'index',
        pageTitle: '1day1pic'
        post: post
        picture1: post.Pictures[seed % 2]
        picture2: post.Pictures[(seed + 1) % 2]

module.exports = postController
