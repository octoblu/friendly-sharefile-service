{Writable} = require 'stream'
crypto     = require 'crypto'
url        = require 'url'
request    = require 'request'
async      = require 'async'
debug      = require('debug')('friendly-sharefile-service:writablechunk')

class WritableChunk extends Writable
  constructor: ({@itemId,@fileName,@fileSize,@requestChunkUri}) ->
    super {objectMode: true}
    @byteOffset = 0
    @index = 0

  _requestChunkUri: (callback) =>
    return callback null if @ChunkUri?
    @requestChunkUri {@itemId,@fileName,@fileSize}, (error, result)=>
      return callback error if error?
      {@ChunkUri,@FinishUri} = result
      callback null

  _write: (chunk, encoding, callback) =>
    @_requestChunkUri (error) =>
      return callback error if error?
      urlObj = url.parse @ChunkUri, true

      delete urlObj.search
      urlObj.query.hash = @_md5 chunk
      urlObj.query.byteOffset = @byteOffset
      urlObj.query.index = @index

      @byteOffset += chunk.length
      @index++

      isLast = @byteOffset == @fileSize
      urlObj.query.finish = isLast
      debug 'if final chunk', isLast, {@byteOffset, @fileSize}
      options =
        body: chunk

      uri = url.format urlObj

      retryOptions = {times: 3,interval:100}
      _makeRequest = async.apply @_makeRequest, uri, options
      async.retry retryOptions, _makeRequest, callback

  _makeRequest: (uri, options, callback) =>
    debug 'post to chunk', uri
    request.post uri, options, (error, response, body) =>
      debug 'chunk result', error, response?.statusCode, body
      return callback code: 500, message: error.message if error?
      return callback code: response.statusCode, message: 'Bad Chunk Upload' if response.statusCode > 299
      callback()

  _md5: (str) =>
    crypto.createHash('md5').update(str).digest('hex')

module.exports = WritableChunk
