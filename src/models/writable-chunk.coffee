{Writable} = require 'stream'
request    = require 'request'
async      = require 'async'
debug      = require('debug')('friendly-sharefile-service:writablechunk')
ChunkUriParser = require './chunk-uri-parser'

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
      isLast = (@byteOffset + chunk.length) == @fileSize

      debug 'if final chunk', isLast, {@byteOffset, @fileSize}
      uri = ChunkUriParser.parse {uri:@ChunkUri,chunk,@byteOffset,@index,isLast}

      @byteOffset += chunk.length
      @index++

      retryOptions = {times: 3,interval:100}
      makeRequest = async.apply @_makeRequest, uri, body: chunk
      async.retry retryOptions, makeRequest, callback

  _makeRequest: (uri, options, callback) =>
    debug 'post to chunk', uri
    request.post uri, options, (error, response, body) =>
      debug 'chunk result', error, response?.statusCode, body
      return callback code: 500, message: error.message if error?
      return callback code: response.statusCode, message: 'Bad Chunk Upload' if response.statusCode > 299
      callback()

module.exports = WritableChunk
