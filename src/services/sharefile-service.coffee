debug   = require 'debug'
request = require 'request'

class SharefileService
  constructor: ({@sharefileUri}) ->

  doShare: ({}, callback) =>

  metadata: (token, callback) =>
    options =
      uri: "#{@sharefileUri}/sf/v3/Shares"
      auth:
        bearer: token

    debug 'request.post', options
    request.post options, (error, response, body) =>
      debug 'request.post result', error, response?.statusCode, body
      debug 'request.post result', error, response?.statusCode, body
      return callback error if error?
      return callback new Error "Error" unless response.statusCode == 201
      callback null


  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = SharefileService
