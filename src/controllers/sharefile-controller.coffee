SharefileService   = require '../services/sharefile-service'

class SharefileController
  metadata: (request, response) =>
    {itemId} = request.params
    @_getShareFileService(request).metadata {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  files: (request, response) =>
    {itemId} = request.params

    @_getShareFileService(request).files {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  list: (request, response) =>

    @_getShareFileService(request).list request.body, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  share: (request, response) =>
    @_getShareFileService(request).share request.body, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  _getShareFileService: (request) =>
    {token,sharefileDomain} = request
    new SharefileService {token, sharefileDomain}

module.exports = SharefileController
