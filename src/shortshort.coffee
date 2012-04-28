

# I took the regex from:
# http://www.igvita.com/2006/09/07/validating-url-in-ruby-on-rails/
httpRegex = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i

class ShortShort

  constructor: (@redis) ->

  shorten: (url, callback) ->
    # validate the URL
    unless httpRegex.test(url)
      callback(message: "not an url")
      return

    @redis.incr "ss-global-counter", (err, globalCounter) =>

      # prepare the result
      result = { key: String(globalCounter) }

      # write to redis
      @redis.set "ss-key-#{result.key}", url, ->
        callback(null, result)

module.exports = ShortShort
