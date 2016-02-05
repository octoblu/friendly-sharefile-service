_       = require 'lodash'
url     = require 'url'
request = require 'request'

class LinkDownload
  download: ({link}, callback) =>
    {link,fileName} = @_getLinkInfo link
    request.get link, (error, response, body) =>
      return callback error if error?
      return callback new Error('Invalid Response') if response.statusCode > 299
      callback null, body, fileName

  _getLinkInfo: (link) =>
    return @_getDropboxLinkInfo link if link.indexOf("dropbox") >= 0
    @_getDefaultLinkInfo link

  _getDropboxLinkInfo: (link) =>
    urlObj = url.parse link, true
    delete urlObj.search
    urlObj.query.dl = 1
    return {
      fileName: decodeURIComponent _.last urlObj.pathname.split('/')
      link: url.format urlObj
    }

  _getDefaultLinkInfo: (link) =>
    urlObj = url.parse link, true
    return {
      fileName: decodeURIComponent _.last urlObj.pathname.split('/')
      link: link
    }


module.exports = LinkDownload
