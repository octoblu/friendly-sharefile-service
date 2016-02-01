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

  list: (request, response) =>
    {body,token,sharefileDomain} = request

    sharefileService = new SharefileService {token, sharefileDomain}
    sharefileService.list body, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

  share: (request, response) =>
    {body,token,sharefileDomain} = request

    sharefileService = new SharefileService {token, sharefileDomain}
    sharefileService.share body, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

module.exports = SharefileController
