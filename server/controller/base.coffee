db = require('../models')

module.exports =
  index: (req, res)->
    # Get last available post with 2 pictures
    db.Post.find({where: {available_pictures: 2}, order: [['date', 'DESC']], include: [db.Picture]})
      .error (error)->
        console.log 'error'
        res.write('404')
      .then (post)->
        # Pictures should be ordered randomly
        seed = Math.floor(Math.random() * 999)

        res.render 'index',
          post: post
          picture1: post.Pictures[seed % 2]
          picture2: post.Pictures[(seed + 1) % 2]
