_       = require 'lodash'
Items   = require '../models/items'
LinkDownload = require '../models/link-download'
WritableChunk = require '../models/writable-chunk'
debug   = require('debug')('friendly-sharefile-service:service')
request = require 'request'

class SharefileService
  constructor: ({@sharefileDomain,@token}) ->

  getMetadataById: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})/Metadata"

    debug 'getMetadataById request options', options
    request.get options, (error, response, body) =>
      debug 'getMetadataById request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, @_createResponse response, body.value

  getMetadataByPath: ({path}, callback) =>
    @getItemByPath {path}, (error, result) =>
      return callback error if error?
      @getMetadataById {itemId: result.body.id}, callback

  shareByPath: ({title, email, path}, callback) =>
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

  getChildrenById: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})/Children"
    options.qs =
      includeDeleted: false
    debug 'getChildren options', options
    request.get options, (error, response, body) =>
      debug 'getChildren result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      items = new Items()
      items.addRawSet body.value
      callback null, @_createResponse response, items.convert()

  getChildrenByPath: ({path}, callback) =>
    @getItemByPath {path}, (error, result) =>
      return callback error if error?
      @getChildrenById {itemId: result.body.id}, callback

  getTreeViewById: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})"
    options.qs =
      treemode: 'manage'
      sourceId: itemId
      canCreateRootFolder:false

    debug 'getTreeViewById options', options
    request.get options, (error, response, body) =>
      debug 'getTreeViewById result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299

      items = new Items()
      items.addRaw body
      callback null, @_createResponse response, items.convert()

  getTreeViewByPath: ({path}, callback) =>
    @getItemByPath {path}, (error, result) =>
      return callback error if error?
      @getTreeViewById {itemId: result.body.id}, callback

  getItemById: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})"

    debug 'getItemsById request options', options
    request.get options, (error, response, body) =>
      debug 'getItemsById request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      items = new Items()
      items.addRawSet body.value
      callback null, @_createResponse response, items.convert()

  getHomeFolder: (callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items"
    debug 'getChildren options', options
    request.get options, (error, response, body) =>
      debug 'getChildren result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, @_createResponse response, Items.ConvertRaw(body)

  getItemByPath: ({path}, callback) =>
    return callback @_createError 422, "Missing path" unless path?
    return callback @_createError 422, "Invalid Path" unless path.indexOf('/') >= 0
    # Home folder is first, so skip it
    segments = _.tail Items.GetPathSegments path
    @getHomeFolder (error, result) =>
      return callback error if error?
      @getItemForPathSegment {item:result.body, segments, path}, callback

      # callback null, @_createResponse statusCode: 200, item
  getItemForPathSegment: ({item, segments, path}, callback) =>
    currentSegment = _.first segments
    return callback null, @_createResponse statusCode: 200, item unless currentSegment?
    @getChildrenById {itemId: item.id}, (error, result) =>
      return callback error if error
      item = _.find result.body, name: currentSegment
      return callback @_createError 404, 'Item not found' unless item?
      # Or be recursive
      item.path = path
      @getItemForPathSegment {item, segments: _.tail(segments), path}, callback

  requestChunkUri: ({itemId, fileName, title, description, fileSize}, callback) =>
    return callback @_createError 422, 'Empty Content' unless fileSize
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})/Upload"
    options.qs =
      method: 'threaded'
      raw: true
      fileName: fileName
      fileSize: fileSize
      title: title ? fileName
      details: description ? "#{fileName} description"
      notify: true
      overwrite: true

    debug 'uploadFileById request options', options
    request.post options, (error, response, body) =>
      debug 'uploadFileById request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, ChunkUri: body.ChunkUri, FinishUri: body.FinishUri

  uploadFileById: ({fileName, title, description, itemId}, fileData, callback) =>
    fileData = JSON.stringify fileData, null, 2 if _.isPlainObject fileData
    @requestChunkUri {itemId, fileName, title, description, fileSize: fileData.length}, (error, result) =>
      return callback error if error?
      request.post result.ChunkUri, body: fileData, (error, response, body) =>
        return callback @_createError 500, error.message if error?
        return callback @_createError response.statusCode, body if response.statusCode > 299
        callback null, @_createResponse {statusCode: 201}, success: true

  uploadFileByPath: ({fileName, title, description, path}, fileData, callback) =>
    @getItemByPath {path}, (error, result) =>
      return callback error if error?
      @uploadFileById {fileName, title, description,itemId: result.body.id}, fileData, callback

  downloadFileById: ({itemId}, callback) =>
    options = @_getRequestOptions()
    options.uri = "/Items(#{itemId})/Download"
    options.qs =
      redirect: false
      includeAllVersions: false

    debug 'downloadFile request options', options
    request.get options, (error, response, body) =>
      debug 'downloadFile request result', error, response?.statusCode, body
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      @_downloadFileFromStorage {uri: body.DownloadUrl}, (error, data) =>
        return callback error if error?
        callback null, @_createResponse statusCode: 200, data

  downloadFileByPath: ({path}, callback) =>
    @getItemByPath {path}, (error, result) =>
      return callback error if error?
      @downloadFileById {itemId: result.body.id}, callback

  transferLinkFileById: ({itemId,link,fileName}, callback) =>
    linkDownload = new LinkDownload()
    autoFileName = linkDownload.getLinkInfo(link).fileName
    fileName ?= autoFileName

    stream = linkDownload.stream {link}
      .on 'response', (response) =>
        fileSize = parseInt response.headers['content-length']
        chunker = new WritableChunk {@requestChunkUri,fileSize,fileName,itemId}
        stream.pipe chunker
          .on 'error', (error) =>
            return callback @_createError error.code, error.message if error?
          .on 'finish', =>
            debug 'FinishUri', chunker.FinishUri
            request.get chunker.FinishUri, json: true, (error, response, body) =>
              return callback @_createError 500, error.message if error?
              callback null, @_createResponse {statusCode: 201}, success: true

  transferLinkFileByPath: ({path,link,fileName}, callback) =>
    @getItemByPath {path}, (error, result) =>
      return callback error if error?
      @transferLinkFileById {itemId: result.body.id,link,fileName}, callback

  _downloadFileFromStorage: ({uri}, callback) =>
    debug 'downloading file from storage', uri
    request.get uri, (error, response, body) =>
      return callback @_createError 500, error.message if error?
      return callback @_createError response.statusCode, body?.message?.value if response.statusCode > 299
      callback null, body

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
