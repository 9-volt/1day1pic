_ = require('lodash')
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
    # Load list of uploaded pictures
    db.Picture.findAll({where: {UserId: req.user.id}, order: [[db.Post, 'date', 'DESC']], include: [db.Post]})
      .then (pictures)->
        message = req.flash 'message'
        # Get first fount picture id from messages
        pictureId = if message? and message.length > 0 then +_.first(message.filter((e)->e.pictureId))?.pictureId else 0

        res.render 'upload',
          layout: 'panel'
          today: dateHelper.getTextFormat(new Date())
          pictures: pictures
          message: message
          pictureId: pictureId
      .catch (error)->
        res.render 'upload',
          layout: 'panel'
          today: dateHelper.getTextFormat(new Date())
          pictures: null
          message: [
            text: 'Failed to load submited pictures'
            type: 'danger'
          ,
            text: error.message
            type: 'info'
          ]

  sendError: (req, res, text='Error')->
    req.flash 'message',
      text: text
      type: 'danger'
    res.redirect('/panel')

  pictureUpload: (req, res)->
    busboy = new Busboy({ headers: req.headers })
    tmpFolderPath = req.app.get('settings').tmpFolderPath
    tmpPicturePath = null
    pictureTitle = 'no title'
    pictureDate = null

    busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
      tmpPicturePath = path.join(tmpFolderPath, filename)
      file.pipe fs.createWriteStream(tmpPicturePath)

    busboy.on 'field', (fieldname, val, fieldnameTruncated, valTruncated)->
      if fieldname is 'title' and val
        pictureTitle = val
      else if fieldname is 'date' and val
        pictureDate = val

    busboy.on 'finish', ()->
      panelController.processFile(req, res, tmpPicturePath, pictureTitle, pictureDate)

    req.pipe busboy # start piping the data.

  processFile: (req, res, picturePath, pictureTitle, pictureDate)->
    sendError = (text)->
      panelController.sendError req, res, text

    if not fs.existsSync(picturePath) then return sendError 'Uploaded picture does not exist'

    # TODO: Check if file is image

    # Extract
    panelController.getExifData picturePath, (err, data)->
      if pictureDate
        date = dateHelper.getUtcDayStart(dateHelper.parseTextFormat(pictureDate))
      else if not err? and data.exif?.DateTimeOriginal?
        exifDate = dateHelper.parseExifFormat(data.exif?.DateTimeOriginal)
        date = dateHelper.getUtcDayStart(exifDate)
      else
        date = dateHelter.getUtcDayStart(new Date()) # today

      panelController.thisDayPictureExists date, req.user, (err, exists)->
        if err then return sendError 'Error while checking for same day image, ' + err.message
        if exists then return sendError 'A picture for this day exists in database'

        pictureThumbPath = picturePath.replace(/(\.[^\.]+)$/, '_thumb$1')

        panelController.createThumbnail picturePath, pictureThumbPath, (err, image)->
          if err then return sendError 'Error while creating thumbnail, ' + err.message

          # Move files to public folder
          publicFolder = req.app.get('settings').picturesFolderPath
          panelController.moveIntoPublic picturePath, pictureThumbPath, publicFolder, pictureTitle, (err, pictureName, thumbnailName)->
            if err then return sendError 'Error while moving pictures into public path'

            panelController.createPicture
              image: pictureName
              thumbnail: thumbnailName
              title: pictureTitle
              date: date
              user: req.user
            , (err, picture)->
              if err
                return sendError 'Error while persisting image to db'
              else
                req.flash 'message',
                  text: 'Successfully added a new picture'
                  type: 'success'
                  pictureId: picture.id
                return res.redirect '/panel'

  getExifData: (picturePath, cb)->
    cbSent = false
    try
      new ExifImage(
        image: picturePath
      , (error, exifData) ->

        if cbSent then return
        cbSent = true

        if error
          return cb(error, null)
        else # Do something with your data!
          return cb(null, exifData)
      )
    catch error
      if cbSent then return
      return cb(error, null)

  thisDayPictureExists: (date, user, cb)->
    db.Post.find({where: {date: date}, include: [db.Picture]})
      .then (post)->
        if post? and post.Pictures?
          myPictures = post.Pictures.filter (picture)->
            picture.UserId is user.id

          cb(null, myPictures.length > 0)
        else
          cb(null, false)
      .catch (err)->
        cb err, null

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

  moveIntoPublic: (picturePath, pictureThumbPath, publicFolder, pictureTitle, cb)->
    pictureName = path.basename(picturePath)
    thumbnailName = path.basename(pictureThumbPath)
    pictureExtension = path.extname(picturePath)
    thumbnailExtension = path.extname(pictureThumbPath)

    # Generate file name from title
    newPictureBaseName = pictureTitle.replace(/[^a-zA-Z0-9 -]/g, '').replace(/\s/, '-')
    newPictureName = newPictureBaseName + pictureExtension
    newThumbnailName = newPictureBaseName + '_thumb' + pictureExtension

    # prevent collisions
    newPictureName = panelController.getUniqueFileName(newPictureName, publicFolder)
    newThumbnailName = panelController.getUniqueFileName(newThumbnailName, publicFolder)

    fs.renameSync(picturePath, path.join(publicFolder, newPictureName))
    fs.renameSync(pictureThumbPath, path.join(publicFolder, newThumbnailName))

    cb null, newPictureName, newThumbnailName

  getUniqueFileName: (fileName, publicFolder, cb)->
    filePath = path.join(publicFolder, fileName)
    fileExtension = path.extname(filePath)
    fileTitle = path.basename(filePath, fileExtension)
    number = 0

    while fs.existsSync(filePath) and number < 1000
      number += 1
      fileName = fileTitle + '_' + number + fileExtension
      filePath = path.join(publicFolder, fileName)

    return fileName

  createPicture: (options, cb)->
    # Get or create Post
    db.Post.getOrCreateByDate options.date, (err, post)->
      # Persist picture in DB
      db.Picture.create
        image: options.image
        thumbnail: options.thumbnail
        title: options.title
      .then (picture)->
        picture.setUser(options.user)
          .then ->
            picture.customSetPost post, (err)->
              if err then cb(err, null)
              cb null, picture
          .catch (err)->
            cb err, null
      .catch (err)->
        cb err, null

  pictureRotate: (req, res)->
    pictureId = req.params.id
    sendError = (text)->
      panelController.sendError req, res, text

    # Find picture
    db.Picture.findById(pictureId)
      .then (picture)->
        thumbnail = path.join req.app.get('settings').picturesFolderPath, picture.thumbnail
        image = path.join req.app.get('settings').picturesFolderPath, picture.image

        panelController.rotate thumbnail, (err)->
          if err then return sendError('Error while rotating thumbnail')

          panelController.rotate image, (err)->
            if err then return sendError('Error while rotating image')

            # Rotate
            req.flash 'message',
              text: 'Succesfully rotated'
              type: 'info'
              pictureId: pictureId
            res.redirect '/panel'
      .catch (err)->
        sendError 'Such picture does not exist in the database'

  rotate: (picturePath, cb)->
    easyimage.rotate
      src: picturePath
      dst: picturePath
      degrees: 90
    .then ->
      cb(null)
    , (err)->
      cb(err)

  pictureDelete: (req, res)->
    publicFolder = req.app.get('settings').picturesFolderPath
    pictureId = req.params.id
    sendError = (text)->
      panelController.sendError req, res, text

    # Check if picture exists
    db.Picture.findById(pictureId)
      .then (picture)->

        pictureName = picture.image
        pictureThumbnail = picture.thumbnail

        # Destroy picture
        picture.destroy()
          .then (id) ->
            # Remove files from server
            fs.unlinkSync(path.join(publicFolder, pictureName))
            fs.unlinkSync(path.join(publicFolder, pictureThumbnail))

            # Success message
            req.flash 'message',
              text: 'Succesfully deleted'
              type: 'info'
            res.redirect '/panel'

          .catch (err)->
            sendError 'Was not able to destroy the picture'

      .catch (err)->
        sendError 'Such picture does not exist in the database'

module.exports = panelController
