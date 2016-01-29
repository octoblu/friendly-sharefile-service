SharefileService   = require '../services/sharefile-service'

class SharefileController
  metadata: (request, response) =>
    {token,sharefileDomain} = request
    {name,itemId} = request.params
    sharefileService = new SharefileService {token, sharefileDomain}
    sharefileService.metadata {name,itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  files: (request, response) =>
    {token,sharefileDomain} = request
    {itemId} = request.params

    sharefileService = new SharefileService {token, sharefileDomain}
    sharefileService.files {itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

module.exports = SharefileController
