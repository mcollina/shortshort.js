expect = require('chai').expect
sinon = require('sinon')
redis = require('redis')

ShortShort = require '../src/shortshort'

describe "shortshort", ->

  before ->
    @client = redis.createClient()
    @client.select 12
    @client.flushdb()

    @subject = new ShortShort(@client)

  after ->
    @client.quit()

  it "should start numbering the shortened url from 1", (done) ->
    @subject.shorten "http://www.google.it", (err, result) ->
      expect(result.key).to.equal("1")
      done()

  it "should store a shortened url in redis", (done) ->
    url = "http://www.google.com"
    @subject.shorten url, (err, result) =>
      @client.get "ss-key-#{result.key}", (err, value) ->
        expect(value).to.equal(url)
        done()

  it "should not shorten a wrong url ", (done) ->
    @subject.shorten "foobar", (err, result) ->
      expect(err.message).to.equal("not an url")
      done()
