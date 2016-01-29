SharefileController = require './controllers/sharefile-controller'

class Router
  constructor: ({@sharefileUri}) ->
  route: (app) =>
    sharefileController = new SharefileController {@sharefileUri}

    # app.post '/share', sharefileController.share

    # app.post '/upload/:itemId', sharefileController.upload
    # app.get '/download/:itemId', sharefileController.download

    app.get '/items/:itemId/metadata/:name', sharefileController.metadata

    # app.get '/change/:itemId', sharefileController.change

    # app.get '/files/:itemId', sharefileController.

module.exports = Router
