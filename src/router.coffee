SharefileController = require './controllers/sharefile-controller'

class Router
  route: (app) =>
    sharefileController = new SharefileController {}

    app.get '/:domain/items', sharefileController.list
    app.get '/:domain/home/folder', sharefileController.getHomeFolder

    # By Path
    app.get '/:domain/items-by-path', sharefileController.getItemByPath
    app.get '/:domain/items-by-path/metadata', sharefileController.getMetadataByPath
    app.get '/:domain/items-by-path/children', sharefileController.getChildrenByPath
    app.get '/:domain/items-by-path/treeview', sharefileController.getTreeViewByPath
    app.get '/:domain/items-by-path/download', sharefileController.downloadFileByPath
    app.post '/:domain/items-by-path/share', sharefileController.shareByPath
    app.post '/:domain/items-by-path/upload', sharefileController.uploadFileByPath
    app.post '/:domain/items-by-path/transfer/link', sharefileController.transferLinkFileByPath

    # By Id
    app.get '/:domain/items/:itemId', sharefileController.getItemById
    app.get '/:domain/items/:itemId/metadata', sharefileController.getMetadataById
    app.get '/:domain/items/:itemId/children', sharefileController.getChildrenById
    app.get '/:domain/items/:itemId/treeview', sharefileController.getTreeViewById
    app.get '/:domain/items/:itemId/download', sharefileController.downloadFileById
    app.post '/:domain/items/:itemId/share', sharefileController.shareById
    app.post '/:domain/items/:itemId/upload', sharefileController.uploadFileById
    app.post '/:domain/items/:itemId/transfer/link', sharefileController.transferLinkFileById


    # Still needs webhooks from ShareFile
    # app.get '/change/:itemId', sharefileController.change

module.exports = Router
