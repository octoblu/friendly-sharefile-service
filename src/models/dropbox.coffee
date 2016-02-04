_       = require 'lodash'
url     = require 'url'
request = require 'request'

class Dropbox
  download: ({link}, callback) =>
    link = @_ensureDownloadLink link
    fileName = @_getFileNameFromLink link
    request.get link, (error, response, body) =>
      return callback error if error?
      return callback new Error('Invalid Response') if response.statusCode > 299
      callback null, body, fileName

  _ensureDownloadLink: (link) =>
    urlObj = url.parse link, true
    delete urlObj.search
    urlObj.query.dl = 1
    url.format urlObj

  _getFileNameFromLink: (link) =>
    urlObj = url.parse link, true
    decodeURIComponent _.last urlObj.pathname.split('/')

module.exports = Dropbox
