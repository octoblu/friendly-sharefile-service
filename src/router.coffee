ShareFileStrategy  = require('passport-sharefile').Strategy;
SharefileController = require './controllers/sharefile-controller'

class Router
  constructor: ({@sharefileService}) ->
  route: (app) =>
    sharefileController = new SharefileController {@sharefileService}
    # console.log 'sharefileController:routes', sharefileController

    # app.post '/share', sharefileController.share

    # app.post '/upload/:itemId', sharefileController.upload
    # app.get '/download/:itemId', sharefileController.download

    # auth?
    app.get '/metadata/:itemId', sharefileController.metadata

    # app.get '/change/:itemId', sharefileController.change

    # app.get '/files/:itemId', sharefileController.



module.exports = Router
