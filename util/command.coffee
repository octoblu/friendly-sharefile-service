#!/usr/bin/env coffee

commander        = require 'commander'
packageJSON      = require '../package.json'

class Command
  constructor: ->

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    commander
      .version packageJSON.version
      .command 'metadata', 'get metadata'
      .parse process.argv

    unless commander.runningCommand
      commander.outputHelp()
      process.exit 1

command = new Command()
command.run()
