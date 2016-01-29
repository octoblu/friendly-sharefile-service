SharefileService   = require '../services/sharefile-service'

class SharefileController
  constructor: ({@sharefileUri}) ->

  metadata: (request, response) =>
    {token,domain} = request
    {name,itemId} = request.params
    sharefileService = new SharefileService {token, @sharefileUri, domain}
    sharefileService.metadata {name,itemId}, (error, result) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(result.code).send result.body

module.exports = SharefileController
