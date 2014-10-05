Base = require('./controller/base')

apiPrefix = '/api/v1'

module.exports =
  bindRoutes: (app)->
    app.get '/', Base.index
