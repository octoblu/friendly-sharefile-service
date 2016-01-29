_       = require 'lodash'
debug   = require('debug')('sharefile-service:serice')
request = require 'request'

class SharefileService
  constructor: ({@sharefileUri,@domain,@token}) ->

  metadata: ({name,itemId}, callback) =>
    options =
      baseUrl: @sharefileUri
      uri: "/Metadata(name=#{name},itemid=#{itemId})"
      json: true
      auth:
        bearer: @token

    debug 'request options', options
    request.get options, (error, response, body) =>
      debug 'request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value unless response.statusCode == 201
      callback null, code: response.statusCode, body: body

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = SharefileService
