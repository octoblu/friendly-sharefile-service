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
      name: item.FileName || item.Name
      originalPath: item.Path
      _raw: item

  addSet: (items) =>
    _.each items, @add

  add: (item) =>
    @items[item.id] = item

  convert: =>
    finalItems = []

    _.each @items, (item, itemId) =>
      pathSegements = _.tail item.originalPath.split('/')
      pathSegements.push itemId
      friendlyPaths = _.map pathSegements, (segment) =>
        return if segment == 'root'
        return @items[segment].name if @items[segment]?
      friendlyPaths = _.compact friendlyPaths
      item.path = "/#{friendlyPaths.join('/')}"
      finalItems.push item

    return finalItems

  getByPath: (path) =>
    return _.find @convert(), path: path

module.exports = Items
