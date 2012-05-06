
base62 = require "base62"

# I took the regex from:
# http://www.igvita.com/2006/09/07/validating-url-in-ruby-on-rails/
httpRegex = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i

class ShortShort

  constructor: (@redis, opts = {}) ->
    throw "A redis connection is needed by ShortShort" unless @redis?
    @validation = true
    @validation = opts.validation if opts.validation?
    @globalCounter = opts.globalCounter || "ss-global-counter"
    @keyPrefix = opts.keyPrefix || "ss-key-"
    @latestList = opts.latestList || "ss-latest-list"
    @latestLength = opts.latestLength - 1 || 9

  shorten: (url, callback) ->

    # validate the URL
    if @validation and not httpRegex.test(url)

      # return an error message if it is not valid
      callback(message: "not an url")
      return

    @redis.incr @globalCounter, (err, globalCounter) =>

      # pass forward the error if redis has problems
      if err?
        callback err 
        return

      # prepare the result
      result = { key: base62.encode(globalCounter) }

      # write to redis
      @redis.set @keyPrefix + result.key, url, =>
        @redis.lpush @latestList, result.key, =>
          @redis.ltrim @latestList, @latestLength, ->
            # nothing to do here
        callback(null, result)


  resolve: (key, callback) ->

    # fetch the value from redis
    @redis.get @keyPrefix + key, (err, value) ->

      # pass forward the error if redis has problems
      if err?
        callback err 
        return

      if value?
        # if we have a value we pass it to the callback
        callback null, value
      else
        # we pass an error message
        callback message: "key not found", null

  update: (key, newValue, callback) ->

    # validate the URL
    if @validation and not httpRegex.test(newValue)

      # return an error message if it is not valid
      callback(message: "not an url")
      return

    @resolve key, (err, oldValue) =>

      # pass forward the error if resolve has problems
      if err?
        callback err 
        return
      
      @redis.set @keyPrefix + key, newValue, (err) ->
        # pass forward the error if resolve has problems
        if err?
          callback err 
          return

        callback(null)

  latest: (callback) ->
    @redis.lrange @latestList, 0, @latestLength, (err, list) ->
      if err?
        callback(err, null)
      else
        callback(null, list)

module.exports = ShortShort
