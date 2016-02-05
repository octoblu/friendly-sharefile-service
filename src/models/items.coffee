_ = require 'lodash'

class Items
  constructor: () ->
    @items = {}

  addRawSet: (items) =>
    _.each items, @addRaw

  addRaw: (item) =>
    return unless item.Id
    @add Items.ConvertRaw item

  addSet: (items) =>
    _.each items, @add

  add: (item) =>
    @items[item.id] = item

  convert: =>
    finalItems = []

    _.each @items, (item) =>
      return unless item?._raw?.Path?
      pathSegements = Items.GetPathSegments item._raw.Path
      path = @_pathToFriendly pathSegements
      item.path = path
      finalItems.push item

    return finalItems

  _pathToFriendly: (pathSegements) =>
    friendlyPaths = _.map pathSegements, (segment) =>
      return @items[segment].name if @items[segment]?
    friendlyPaths = _.compact friendlyPaths
    "/#{friendlyPaths.join('/')}"

  @GetPathSegments: (path='/') =>
    path = _.trim(path)
    path = _.trimEnd path, '/' unless path == '/'
    pathSegements = path.split('/')
    pathSegements = _.without pathSegements, 'root'
    pathSegements = _.tail pathSegements
    pathSegements

  @ConvertRaw: (item) =>
    return {
      id: item.Id
      path: null
      name: item.FileName || item.Name
      creationDate: item.CreationDate
      expirationDate: item.ExpirationDate
      hidden: item.IsHidden
      fileSizeBytes: item.FileSizeBytes
      _raw: item
    }

module.exports = Items
