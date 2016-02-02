SharefileController = require './controllers/sharefile-controller'

class Router
  route: (app) =>
    sharefileController = new SharefileController {}


    # app.post '/upload/:itemId', sharefileController.upload
    # app.get '/download/:itemId', sharefileController.download

    app.get '/items', sharefileController.list
    app.get '/items/:itemId/metadata', sharefileController.metadata
    app.get '/items/:itemId/children', sharefileController.getChildren
    app.get '/items/:itemId/treeview', sharefileController.getTreeView
    app.get '/items/:itemId', sharefileController.getItemsById
    app.get '/folders/home', sharefileController.getHomeFolder

    app.post '/share/:itemId', sharefileController.shareById
    app.post '/share', sharefileController.shareByPath
    # Still needs webhooks from ShareFile
    # app.get '/change/:itemId', sharefileController.change

module.exports = Router
