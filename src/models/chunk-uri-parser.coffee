url = require 'url'
crypto = require 'crypto'

class ChunkUriParser
  @parse: ({uri,chunk,byteOffset,index,isLast}) =>
    urlObj = url.parse uri, true

    delete urlObj.search
    urlObj.query.hash = ChunkUriParser.md5 chunk
    urlObj.query.byteOffset = byteOffset
    urlObj.query.index = index
    urlObj.query.finish = isLast

    url.format urlObj

  @md5: (str) =>
    crypto.createHash('md5').update(str).digest('hex')

module.exports = ChunkUriParser
