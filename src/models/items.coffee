_ = require 'lodash'

class Items
  constructor: () ->
    @items = {}

  addRawSet: (items) =>
    _.each items, @addRaw

  addRaw: (item) =>
    return unless item.Id
    @add
      id: item.Id
      path: null
      name: item.FileName || item.Name
      parentId: item.Parent.Id
      creationDate: item.CreationDate
      expirationDate: item.ExpirationDate
      hidden: item.IsHidden
      fileSizeBytes: item.FileSizeBytes
      _raw: item

  addSet: (items) =>
    _.each items, @add

  add: (item) =>
    @items[item.id] = item

  convert: =>
    finalItems = []

    _.each @items, (item, itemId) =>
      return unless item?._raw?.Path?
      pathSegements = _.tail item._raw.Path.split('/')
      pathSegements.push itemId
      friendlyPaths = _.map pathSegements, (segment) =>
        return if segment == 'root'
        return @items[segment].name if @items[segment]?
      friendlyPaths = _.compact friendlyPaths
      item.path = "/#{friendlyPaths.join('/')}"
      finalItems.push item

    return finalItems

  getByPath: (path) =>
    path = _.trimEnd path, '/'
    return _.find @convert(), path: path

module.exports = Items
