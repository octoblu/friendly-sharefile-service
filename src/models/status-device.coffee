MeshbluHttp = require 'meshblu-http'

class StatusDevice
  constructor: ({@meshbluConfig}) ->
    @meshbluHttp = new MeshbluHttp @meshbluConfig

  create: ({link}, callback) =>
    deviceProperties =
      name: 'Sharefile Device Status'
      type: 'sharefile:status'
      sharefile:
        link: link
        progress: 0
        done: false
      configureWhitelist: [@meshbluConfig.uuid]
      receiveWhitelist: ['*']
      sendWhitelist: ['*']
      discoverWhitelist: [@meshbluConfig.uuid]
      owner: @meshbluConfig.uuid

    @meshbluHttp.register deviceProperties, callback

module.exports = StatusDevice
