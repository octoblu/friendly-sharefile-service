http    = require 'http'
request = require 'request'
shmock  = require '@octoblu/shmock'
Server  = require '../../src/server'

describe 'Test', ->
  beforeEach (done) ->
    serverOptions =
      port: undefined,
      disableLogging: true
      
    @server = new Server serverOptions, {}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  it 'should boot up', ->
    expect(true).to.be.true
