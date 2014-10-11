Post = require('./controller/post')

apiPrefix = '/api/v1'

module.exports =
  bindRoutes: (app)->
    app.get '/', Post.getIndex
    app.get '/post/:date', Post.getDate
