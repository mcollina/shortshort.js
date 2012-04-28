
base62 = require "base62"

# I took the regex from:
# http://www.igvita.com/2006/09/07/validating-url-in-ruby-on-rails/
httpRegex = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i

class ShortShort

  constructor: (@redis) ->
    throw "A redis connection is needed by ShortShort" unless @redis?

  shorten: (url, callback) ->

    # validate the URL
    unless httpRegex.test(url)

      # return an error message if it is not valid
      callback(message: "not an url")
      return

    @redis.incr "ss-global-counter", (err, globalCounter) =>

      # pass forward the error if redis has problems
      callback(err, null) if err?

      # prepare the result
      result = { key: base62.encode(globalCounter) }

      # write to redis
      @redis.set "ss-key-#{result.key}", url, ->
        callback(null, result)

  resolve: (key, callback) ->

    # fetch the value from redis
    @redis.get "ss-key-#{key}", (err, value) ->

      # pass forward the error if redis has problems
      callback err if err?

      if value?
        # if we have a value we pass it to the callback
        callback null, value
      else
        # we pass an error message
        callback message: "key not found", null

module.exports = ShortShort
