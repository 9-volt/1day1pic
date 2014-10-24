moment = require 'moment'

module.exports =
  getUtcDayStart: (date)->
    paramDate = moment(date)

    utcDayStart = moment()
      .zone(0)
      .year(paramDate.year())
      .month(paramDate.month())
      .date(paramDate.date())
      .hour(0)
      .minute(0)
      .second(0)
      .toDate()

  getUrlFormat: (date)->
    moment(date).format('DDMMMYYYY')

  parseUrlFormat: (str)->
    moment(str, 'DDMMMYYYY').toDate()

  parseExifFormat: (str)->
    moment(str, 'YYYY:MM:DD HH:mm:ss')

  getTextFormat: (date)->
    moment(date).format('DD-MM-YYYY')

  parseTextFormat: (str)->
    moment(str, 'DD-MM-YYYY')
