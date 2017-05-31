SharefileService   = require '../services/sharefile-service'

class SharefileController
  constructor: ({@meshbluConfig,@jobManager}) ->

  getMetadataById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getMetadata {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getMetadataByPath: (request, response) =>
    {path} = request.query

    @_getShareFileService(request).getMetadata {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getItemById: (request, response) =>
    {itemId} = request.params

    @_getShareFileService(request).getItem {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getItemByPath: (request, response) =>
    {path} = request.query

    @_getShareFileService(request).getItem {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  shareById: (request, response) =>
    {itemId} = request.params
    {email, title} = request.body

    @_getShareFileService(request).share {itemId, email, title}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  shareByPath: (request, response) =>
    {path} = request.query
    {email, title} = request.body

    @_getShareFileService(request).share {path, email, title}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getHomeFolder: (request, response) =>
    @_getShareFileService(request).getHomeFolder (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getTreeViewById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getTreeView {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getTreeViewByPath: (request, response) =>
    {path} = request.query
    @_getShareFileService(request).getTreeView {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getChildrenById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getChildren {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getChildrenByPath: (request, response) =>
    {path} = request.query
    @_getShareFileService(request).getChildren {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  uploadFileById: (request, response) =>
    {itemId} = request.params
    {fileName,title,description,contents} = request.body

    @_getShareFileService(request).uploadFile {itemId,fileName,title,description}, contents, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  uploadFileByPath: (request, response) =>
    {path} = request.query
    {fileName,title,description,contents} = request.body

    @_getShareFileService(request).uploadFile {path,fileName,title,description}, contents, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  downloadFileById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).downloadFile {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  downloadFileByPath: (request, response) =>
    {path} = request.query
    @_getShareFileService(request).downloadFile {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  initiateTransferById: (request, response) =>
    {itemId} = request.params
    {uuid} = request.query
    {link,fileName} = request.body

    @_getShareFileService(request).initiateTransfer {itemId,uuid,fileName,link}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  initiateTransferByPath: (request, response) =>
    {path,uuid} = request.query
    {link,fileName} = request.body

    @_getShareFileService(request).initiateTransfer {path,uuid,fileName,link}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  _getShareFileService: (request) =>
    {token} = request
    sharefileDomain = request.params.domain
    new SharefileService {token, sharefileDomain,@jobManager,@meshbluConfig}

module.exports = SharefileController
