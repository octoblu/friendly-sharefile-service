_       = require 'lodash'
Items   = require '../models/items'
debug   = require('debug')('friendly-sharefile-service:service')
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

  getItemsById: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(id=#{itemId})"

    debug 'request options', options
    request.get options, (error, response, body) =>
      debug 'request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      items = new Items()
      items.addRawSet body.value
      callback null, @_createResponse response, items.convert()

  shareByPath: ({title, email, path}, callback) =>
    return callback @_createError 422, "Missing path" unless path?

    @getItemByPath {path}, (error, result) =>
      return callback error if error?
      @shareById {title, email, itemId: result.body.id}, callback

  shareById: ({title, email, itemId}, callback) =>
    body =
      ShareType: 'Send'
      RequireLogin: false
      RequireUserInfo: false
      MaxDownloads: -1
      UsesStreamIDs: false

    return callback @_createError 422, "Missing title" unless title?
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

  getHomeFolder: ({}, callback) =>
    options = @_getRequestOptions()
    options.uri = '/Items'

    #Get HomeFolder for Current User
    request.get options, (error, response, body) =>
      debug 'HomeFolder result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      items = new Items()
      items.addRaw body
      callback null, @_createResponse response, items.convert()

  getChildren: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(id=#{itemId})/Children"

    request.get options, (error, response, body) =>
      debug 'children result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299

      items = new Items()
      items.addRawSet body.value
      callback null, @_createResponse response, items.convert()

  getTreeView: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})"
    options.qs =
      treemode: 'mode'
      sourceId: itemId
      canCreateRootFolder:false

    request.get options, (error, response, body) =>
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299

      items = new Items()
      items.addRawSet body
      callback null, @_createResponse response, items.convert()

  list: ({}, callback) =>
    items = new Items()
    @getHomeFolder {}, (error, result) =>
      return callback error if error?
      {Id} = result.body
      items.addSet result.body

      @getChildren {itemId:Id}, (error, result) =>
        return callback error if error?
        items.addSet result.body
        callback null, @_createResponse statusCode: 200, items.convert()

  getItemByPath: ({path}, callback) =>
    @list {}, (error, result) =>
      return callback error if error?
      items = new Items()
      items.addSet result.body
      item = items.getByPath path
      return callback @_createError 404, 'Item not found' unless item?
      callback null, @_createResponse statusCode: 200, item

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
