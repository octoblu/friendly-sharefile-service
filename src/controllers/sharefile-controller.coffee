SharefileService   = require '../services/sharefile-service'

class SharefileController
  metadata: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).metadata {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getItemsById: (request, response) =>
    {itemId} = request.params

    @_getShareFileService(request).getItemsById {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  list: (request, response) =>
    @_getShareFileService(request).list request.body, (error, result) =>
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
    @_getShareFileService(request).getHomeFolder request.body, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getTreeView: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getTreeView {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  getChildren: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).getChildren {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  _getShareFileService: (request) =>
    {token,sharefileDomain} = request
    new SharefileService {token, sharefileDomain}

module.exports = SharefileController
