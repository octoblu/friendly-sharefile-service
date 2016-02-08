_            = require 'lodash'
uuid         = require 'uuid'
StatusDevice = require 'friendly-sharefile/src/models/status-device'

class SharefileService
  constructor: ({@token,@sharefileDomain,@jobManager,@meshbluConfig}) ->

  getMetadata: ({itemId,path}, callback) =>
    @_do 'getMetadata', {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  getItem: ({itemId,path}, callback) =>
    @_do 'getItem', {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  share: ({itemId,path,email,title}, callback) =>
    @_do 'share', {itemId,path,email,title}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  getHomeFolder: (callback) =>
    @_do 'getHomeFolder', {}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  getTreeView: ({itemId,path}, callback) =>
    @_do 'getTreeView', {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  getChildren: ({itemId,path}, callback) =>
    @_do 'getChildren', {itemId,path}, {}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  uploadFile: ({itemId,path,fileName,title,description}, contents, callback) =>
    @_do 'uploadFile', {itemId,path,fileName,title,description}, contents, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  downloadFile: ({itemId,path}, callback) =>
    @_do 'downloadFile', {itemId,path}, (error, response) =>
      return callback @_createError 500, error.message if error?
      {code} = result.metadata
      body = JSON.parse result.rawData
      callback null, @_createResponse code, body

  initiateTransfer: ({itemId,path,link,fileName}, callback) =>
    statusDevice = new StatusDevice {@meshbluConfig}
    statusDevice.create {}, (error, device) =>
      return callback @_createError 500, error.message if error?
      deviceConfig = _.cloneDeep @meshbluConfig
      deviceConfig.uuid = device.uuid
      deviceConfig.token = device.token
      message =
        metadata:
          statusDevice: deviceConfig
          responseId: uuid.v4()
          link: link
          fileName: fileName
          itemId: itemId
          path: path
          token: @token
          domain: @sharefileDomain
        data: {}
      @jobManager.createRequest 'request', message, (error) =>
        return callback @_createError 500, error.message if error?
        response =
          uploading: true
          background: true
          statusDevice:
            uuid: device.uuid
        callback null, @_createResponse 201, response

  _do: (jobType, metadata, data, callback) =>
    metadata.token = @token
    metadata.domain = @sharefileDomain
    metadata.jobType = jobType
    @jobManager.do 'request', 'response', {metadata,data}, callback

  _createResponse: (code, body) =>
    return code: code, body: body

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = SharefileService
