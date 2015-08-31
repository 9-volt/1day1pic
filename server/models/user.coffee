crypto = require('crypto')

module.exports = (sequelize, DataTypes)->
  User = sequelize.define 'User',
    id:
      type: DataTypes.INTEGER
      autoIncrement: true
      primaryKey: true
    name:
      type: DataTypes.STRING(32)
      defaultValue: 'No name'
    email:
      type: DataTypes.STRING
      allowNull: false
    password:
      type: DataTypes.STRING
      allowNull: false
  ,
    classMethods:
      associate: (models)->
        User.hasMany(models.Picture)

    instanceMethods:

      makeSalt: ->
        crypto.randomBytes(8).toString 'base64'

      authenticate: (plainText) ->
        if ~@password.indexOf(':')
          # If encripted password
          [salt, password] = @password.split(':')
          return @encryptPassword(plainText, salt) is password
        else
          # If plain text password
          return plainText is @password

      encryptPassword: (password, salt) ->
        return ''  if not password or not salt
        salt = new Buffer(salt, 'base64')
        crypto.pbkdf2Sync(password, salt, 10000, 64).toString 'base64'

      updatePassword: (plainText) ->
        salt = @makeSalt()
        newPassword = salt + ':' + @encryptPassword(plainText, salt)

        @updateAttributes({
          password: newPassword
        })
