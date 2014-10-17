fs = require('fs')
path = require('path')
db = require('../models')
passport = require('../helpers/passport')
Busboy = require('busboy')
ExifImage = require('exif').ExifImage
easyimage = require('easyimage')
dateHelper = require('../helpers/date')

panelController =
  get: (req, res)->
    res.render 'upload',
      layout: 'panel'

  pictureUpload: (req, res)->
    busboy = new Busboy({ headers: req.headers })
    tmpFolderPath = req.app.get('settings').tmpFolderPath
    tmpPicturePath = null
    pictureTitle = 'no title'

    busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
      tmpPicturePath = path.join(tmpFolderPath, filename)
      file.pipe fs.createWriteStream(tmpPicturePath)

    busboy.on 'field', (fieldname, val, fieldnameTruncated, valTruncated)->
      if fieldname is 'title' and val
        pictureTitle = val

    busboy.on 'finish', ()->
      panelController.processFile(req, res, tmpPicturePath, pictureTitle)

    req.pipe busboy # start piping the data.

  processFile: (req, res, picturePath, pictureTitle)->
    if not fs.existsSync(picturePath) then return res.send '404 - uploaded picture does not exist'

    # TODO: Check if file is image

    # Extract
    panelController.getExifData picturePath, (err, data)->
      if err then return res.send '404 - error extracting exif data from image, ' + err.message

      exifDate = dateHelper.parseExifFormat(data.exif?.DateTimeOriginal)
      date = dateHelper.getUtcDayStart(exifDate)

      panelController.thisDayPictureExists date, req.user, (err, exists)->
        if err then return res.send '404 - error while checking for same day image', + err.message
        if exists then return res.send '404 - a picture for this day exists in database'

        pictureThumbPath = picturePath.replace(/(\.[^\.]+)$/, '_thumb$1')

        panelController.createThumbnail picturePath, pictureThumbPath, (err, image)->
          if err then return res.send '404 - error while creating thumbnail, ' + err.message

          # Move files to public folder
          publicFolder = req.app.get('settings').picturesFolderPath
          panelController.moveIntoPublic picturePath, pictureThumbPath, publicFolder, (err, pictureName, thumbnailName)->
            if err then return res.send '404 - error while moving pictures into public path'

            panelController.createPicture
              image: pictureName
              thumbnail: thumbnailName
              title: pictureTitle
              date: date
              user: req.user
            , (err, picture)->
              if err then return res.send '404 - error while persisting image to db'
              return res.send 'success, id: ' + picture.id

  getExifData: (picturePath, cb)->
    try
      new ExifImage(
        image: picturePath
      , (error, exifData) ->
        if error
          return cb(error, null)
        else # Do something with your data!
          return cb(null, exifData)
      )
    catch error
      return cb(error, null)

  thisDayPictureExists: (date, user, cb)->
    db.Post.find({where: {date: date}, include: [db.Picture]})
      .error (err)->
        cb err, null
      .success (post)->
        if post? and post.Pictures?
          myPictures = post.Pictures.filter (picture)->
            picture.UserId is user.id

          cb(null, myPictures.length > 0)
        else
          cb(null, false)

  createThumbnail: (picturePath, pictureThumbPath, cb)->
    # Get info about image
    easyimage.info picturePath
    .then (info)->
      thumbnailWidth = Math.min(info.width, info.height, 1000)

      # Create thumbnail
      easyimage.thumbnail
        src: picturePath
        dst: pictureThumbPath
        width: thumbnailWidth
      .then (image)->
        cb(null, image)
      , (err)->
        cb(err, null)

  moveIntoPublic: (picturePath, pictureThumbPath, publicFolder, cb)->
    # TODO: prevent collisions
    pictureName = path.basename(picturePath)
    thumbnailName = path.basename(pictureThumbPath)

    fs.renameSync(picturePath, path.join(publicFolder, pictureName))
    fs.renameSync(pictureThumbPath, path.join(publicFolder, thumbnailName))

    cb null, pictureName, thumbnailName

  createPicture: (options, cb)->
    # Get or create Post
    db.Post.getOrCreateByDate options.date, (err, post)->
      # Persist picture in DB
      db.Picture.create
        image: options.image
        thumbnail: options.thumbnail
        title: options.title
      .error (err)->
        cb err, null
      .success (picture)->
        picture.setUser(options.user)
          .error (err)->
            cb err, null
          .success ->
            picture.customSetPost post, (err)->
              if err then cb(err, null)
              cb null, picture

module.exports = panelController
