SharefileController = require './controllers/sharefile-controller'

class Router
  route: (app) =>
    sharefileController = new SharefileController {}

    app.post '/share', sharefileController.share

    # app.post '/upload/:itemId', sharefileController.upload
    # app.get '/download/:itemId', sharefileController.download

    app.get '/items/:itemId/metadata', sharefileController.metadata

    # Still needs webhooks from ShareFile
    # app.get '/change/:itemId', sharefileController.change

    app.get '/files/:itemId', sharefileController.files
    app.post '/folders', sharefileController.list



module.exports = Router
