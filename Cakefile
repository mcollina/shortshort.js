
{ spawn } = require('child_process')
process = global.process
path = require('path')

runExternal = (command, callback) ->
  console.log("Running #{command}")
  child = spawn("/bin/sh", ["-c", command])
  child.stdout.on "data", (data) -> process.stdout.write(data)
  child.stderr.on "data", (data) -> process.stderr.write(data)
  child.on('exit', callback) if callback?

launchSpec = (args...) ->
  runExternal "./node_modules/.bin/mocha --compilers coffee:coffee-script " + args.join(" ")

task "spec", ->
  launchSpec()

task "spec:ci", ->
  launchSpec("--watch")

task "build", ->
  runExternal "rm -rf ./lib", ->
    runExternal "./node_modules/.bin/coffee -o lib -c src/*.coffee"
