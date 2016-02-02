_       = require 'lodash'
debug   = require('debug')('sharefile-service:service')
request = require 'request'

class SharefileService
  constructor: ({@sharefileDomain,@token}) ->

  metadata: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})/Metadata"

    debug 'request options', options
    request.get options, (error, response, body) =>
      debug 'request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, @_createResponse response, body

  files: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(id=#{itemId})"

    debug 'request options', options
    request.get options, (error, response, body) =>
      debug 'request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, @_createResponse response, body

  share: ({title, email, itemId}, callback) =>
    body =
      ShareType: 'Send'
      RequireLogin: false
      RequireUserInfo: false
      MaxDownloads: -1
      UsesStreamIDs: false

    return callback @_createError 422, "Missing title" unless title?
    return callback @_createError 422, "Missing itemId" unless itemId?
    return callback @_createError 422, "Missing email" unless email?

    body.Title = title
    body.Recipients = [User: Email: email]
    body.Items = [Id: itemId]

    options = @_getRequestOptions()
    options.uri = "/Shares"
    options.qs =
      notify: false
    options.json = body

    debug 'request options', options
    request.post options, (error, response, body) =>
      debug 'request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, @_createResponse response, body

  list: ({}, callback) =>
    options = @_getRequestOptions()
    options.uri = '/Items'

    #Get HomeFolder for Current User
    request.get options, (error, response, body) =>
      debug 'HomeFolder result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299

      debug 'HomeFolder Id', body.Id
      {Id} = body

      #Get Children
      childrenOptions = @_getRequestOptions()
      childrenOptions.uri = "/Items(id=#{Id})/Children"

      request.get childrenOptions, (error, response, body) =>
        debug 'children result', error, response?.statusCode, body
        return callback @_createError 500, error.message if error?
        return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
        callback null, @_createResponse response, body

  _getRequestOptions: =>
    return {
      baseUrl: "https://#{@sharefileDomain}.sf-api.com/sf/v3/"
      json: true
      auth:
        bearer: @token
    }

  _createResponse: (response, body) =>
    return code: response.statusCode, body: body

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = SharefileService
