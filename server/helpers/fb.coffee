request = require 'request'
moment = require 'moment'
db = require('../models')
app = require('./app')
easyimage = require('easyimage')
path = require('path')
dateHelper = require('./date')

###
  * Search for posts with 2 unpublished pictures
  * Search for posts with 1 unpublished picture older than 3 days

  # Publishing a 2 pictures post:
  * Create a concatenated image
  * Create a concatenated description

  # Publishing a 1 picture post
  * Publish normal image
  * Publish normal description
###

module.exports =
  start: ->
    # Setup an interval to check for images

    setInterval =>
      @publishToFacebook()
    , 13333 * 1000 # Every 3 hours, 42 mins and 13 sec

    @publishToFacebook()

  publishToFacebook: ->
    @getPostId()
      .then @loadPicturesByPostId
      .then @getPicturesThumbnail
      .then @postPictures
      .then @markAsPosted
      .catch (err)->
        console.log 'FB Publishing error: ', err

  getPostId: ->
    new Promise (resolve, reject)=>
      # Chain of responsibility
      @postWith2UnpublishedPictures()
        .catch @postWith1UnpublishedPicture
        .then (postId)->
          resolve postId
        .catch (err)->
          reject err

  postWith2UnpublishedPictures: ->
    new Promise (resolve, reject)->
      db.Picture.find
        attributes: ['PostId', [db.Sequelize.fn('count', db.Sequelize.col('PostId')), 'counted']]
        where:
          posted_to_fb: $or: [0, null]
        group: ['PostId']
        having: ['COUNT(PostId) = ?', 2]
        order: [db.Sequelize.fn('RAND')]

      .then (picture)->
        if picture
          resolve picture.PostId
        else
          reject()

      .catch (err)->
        reject err

  postWith1UnpublishedPicture: ->
    new Promise (resolve, reject)->
      db.Picture.find
        attributes: ['PostId', [db.Sequelize.fn('count', db.Sequelize.col('PostId')), 'counted']]
        where:
          posted_to_fb: $or: [0, null]
        group: ['PostId']
        having: ['COUNT(PostId) = ?', 1]
        order: [db.Sequelize.fn('RAND')]
        include: [
          model: db.Post
          where: date: {lt: new Date(Date.now() - 86400000*3)}
        ]

      .then (picture)->
        if picture
          resolve picture.PostId
        else
          reject new Error 'No unpublished picture found'

      .catch (err)->
        reject err

  loadPicturesByPostId: (postId)->
    new Promise (resolve, reject)->
      db.Picture.findAll
        where:
          posted_to_fb: $or: [0, null]
          PostId: postId
        include: [db.Post]

      .then (pictures)->
        if pictures
          resolve pictures
        else
          reject new Error 'No pictures found'

      .catch (err)->
        reject err

  getPicturesThumbnail: (pictures)->
    new Promise (resolve, reject)->
      if pictures.length is 0
        reject new Error 'No pictures to create a thumbnail from'
      else if pictures.length is 1
        pictures.thumbnail = pictures[0].thumbnail
        resolve pictures
      else
        thumbnailPath1 = path.join app.get('settings').picturesFolderPath, pictures[0].thumbnail
        thumbnailPath2 = path.join app.get('settings').picturesFolderPath, pictures[1].thumbnail
        thumbnail = dateHelper.getUrlFormat(pictures[0].Post.date) + '.jpg'
        thumbnailPath = path.join app.get('settings').picturesFolderPath, thumbnail

        # Concat thumbnails
        easyimage.exec [thumbnailPath1, thumbnailPath2, '+append', thumbnailPath]
        .then ->
          pictures.thumbnail = thumbnail
          resolve pictures
        , (err)->
          reject err

  postPictures: (pictures)->
    new Promise (resolve, reject)->
      postDate = pictures[0].Post.date
      urlDate = dateHelper.getUrlFormat(postDate)
      link = app.get('settings').config.baseUrl + '/post/' + urlDate
      picture = app.get('settings').config.baseUrl + '/pictures/' + pictures.thumbnail
      titles = []

      if pictures[0].title isnt 'no title'
        titles.push pictures[0].title
      if pictures.length > 1 && pictures[1].title isnt 'no title'
        titles.push pictures[1].title

      if titles.length is 0
        description = 'These pictures have no title oO'
      else if titles.length is 1
        description = titles[0]
      else
        description = '"' + titles.join('" and "') + '"'

      request
        .post "https://graph.facebook.com/v2.5/#{app.get('settings').config.facebookPageId}/feed"
        .form
          access_token: app.get('settings').config.facebookPageToken
          # backdated_time: Math.floor(postDate.getTime())
          link: link
          picture: picture
          name: "Picture#{pictures.length > 1 ? 's' : ''} from #{moment(postDate).format('DD MMM YYYY')}"
          caption: link.replace(/^(https?|ftp):\/\//, '') # Remove http part
          description: description

        .on 'response', (response)->
          response.on 'data', (data)->
            dataObject = JSON.parse(data.toString())

            # Error
            if dataObject.error?
              reject dataObject.error.message
            else
              console.log 'Success, post id: ', dataObject.id
              resolve pictures

        .on 'error', (err)->
          reject err

  markAsPosted: (pictures)->
    promises = []
    for picture in pictures
      promises.push picture.update
        posted_to_fb: 'true'

    Promise.all promises
