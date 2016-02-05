_       = require 'lodash'
url     = require 'url'
request = require 'request'

class LinkDownload
  stream: ({link}) =>
    {link} = @getLinkInfo link
    return request.get link

  download: ({link}, callback) =>
    {link,fileName} = @getLinkInfo link
    request.get link, (error, response, body) =>
      return callback error if error?
      return callback new Error('Invalid Response') if response.statusCode > 299
      callback null, body, fileName

  getLinkInfo: (link) =>
    return @_getDefaultLinkInfo link if link.indexOf("dropboxusercontent.com") >= 0
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
