_       = require 'lodash'
debug   = require('debug')('sharefile-service:serice')
request = require 'request'

class SharefileService
  constructor: ({@sharefileDomain,@token}) ->

  metadata: ({name,itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Metadata(name=#{name},itemid=#{itemId})"

    debug 'request options', options
    request.get options, (error, response, body) =>
      debug 'request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, code: response.statusCode, body: body

  files: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(id=#{itemId})"

    debug 'request options', options
    request.get options, (error, response, body) =>
      debug 'request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, code: response.statusCode, body: body

  _getRequestOptions: =>
    return {
      baseUrl: "https://#{@sharefileDomain}.sf-api.com/sf/v3/"
      json: true
      auth:
        bearer: @token
    }

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = SharefileService
