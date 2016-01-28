
class SharefileController
  constructor: ({@sharefileService}) ->

  metadata: (request, response) =>
    {token} = request.token
    @sharefileService.metadata {token}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(200)


module.exports = SharefileController
