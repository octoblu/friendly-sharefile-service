SharefileService   = require '../services/sharefile-service'

class SharefileController
  getMetadataById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getMetadataById {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getMetadataByPath: (request, response) =>
    {path} = request.query

    @_getShareFileService(request).getMetadataByPath {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getItemById: (request, response) =>
    {itemId} = request.params

    @_getShareFileService(request).getItemById {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getItemByPath: (request, response) =>
    {path} = request.query

    @_getShareFileService(request).getItemByPath {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  list: (request, response) =>
    @_getShareFileService(request).list (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  shareById: (request, response) =>
    {itemId} = request.params
    {email, title} = request.body

    @_getShareFileService(request).shareById {itemId, email, title}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  shareByPath: (request, response) =>
    {email, title, path} = request.body

    @_getShareFileService(request).shareByPath {path, email, title}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getHomeFolder: (request, response) =>
    @_getShareFileService(request).getHomeFolder (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getTreeViewById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getTreeViewById {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getTreeViewByPath: (request, response) =>
    {path} = request.query
    @_getShareFileService(request).getTreeViewByPath {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getChildrenById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getChildrenById {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getChildrenByPath: (request, response) =>
    {path} = request.query
    @_getShareFileService(request).getChildrenByPath {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  uploadFileById: (request, response) =>
    {itemId} = request.params
    {fileName,title,description,batchId,batchLast} = request.query
    @_getShareFileService(request).uploadFileById {itemId,fileName,title,description,batchId,batchLast}, request.body, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  uploadFileByPath: (request, response) =>
    {path,fileName,title,description,batchId,batchLast} = request.query
    @_getShareFileService(request).uploadFileByPath {path,fileName,title,description,batchId,batchLast}, request.body, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  downloadFileById: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).downloadFileById {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  downloadFileByPath: (request, response) =>
    {path} = request.query
    @_getShareFileService(request).downloadFileByPath {path}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  _getShareFileService: (request) =>
    {token} = request
    sharefileDomain = request.query.domain
    new SharefileService {token, sharefileDomain}

module.exports = SharefileController
