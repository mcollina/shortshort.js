expect = require('chai').expect
sinon = require('sinon')
redis = require('redis')

ShortShort = require '../src/shortshort'

describe "ShortShort", ->

  beforeEach (done) ->
    @client = redis.createClient()
    @client.select 12
    @client.flushdb =>
      @subject = new ShortShort(@client)
      done()

  afterEach ->
    @client.quit()

  it "should start numbering the shortened urls from 1", (done) ->
    @subject.shorten "http://www.google.it", (err, result) ->
      expect(result.key).to.equal("1")
      done()

  it "should increment the key", (done) ->
    @subject.shorten "http://www.google.com", (err, result) =>
      @subject.shorten "http://www.google.it", (err, result) ->
        expect(result.key).to.equal("2")
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

  it "should increment a global counter when shortening", (done) ->
    @subject.shorten "http://www.google.it", (err, result) =>
      @client.get "ss-global-counter", (err, value) ->
        expect(value).to.equal("1")
        done()

  it "should increment a global counter when shortening (bis)", (done) ->
    @subject.shorten "http://www.google.com", (err, result) =>
      @subject.shorten "http://www.google.it", (err, result) =>
        @client.get "ss-global-counter", (err, value) ->
          expect(value).to.equal("2")
          done()

  it "should be able to resolve a reference", (done) ->
    @subject.shorten "http://www.google.com", (err, result) =>
      @subject.resolve result.key, (err, url) =>
        expect(url).to.equal("http://www.google.com")
        done()

  it "should be able to resolve a wrong refernce", (done) ->
    @subject.resolve "abc", (err, url) =>
      expect(err.message).to.equal("key not found")
      done()

  it "should encode the key using a base62 algorithm", (done) ->
    @client.set "ss-global-counter", 195948556, =>
      @subject.shorten "http://www.google.com", (err, result) =>
        # the expected value is 195948557,
        # but as it should be encoded in base62,
        # we expect dgbaB
        expect(result.key).to.equal("dgbaB")
        done()

  it "might be instructed to skip the url validation", (done) ->
    @subject = new ShortShort(@client, validation: false)
    
    @subject.shorten "foobar", (err, result) ->
      expect(err).to.equal(null)
      done()

  it "might have a different global counter", (done) ->
    @subject = new ShortShort(@client, globalCounter: "custom-global-counter")

    @subject.shorten "http://www.google.it", (err, result) =>
      @client.get "custom-global-counter", (err, value) ->
        expect(value).to.equal("1")
        done()

  it "might have a different key prefix", (done) ->
    @subject = new ShortShort(@client, keyPrefix: "custom-key-")

    url = "http://www.google.it"
    @subject.shorten url, (err, result) =>
      @client.get "custom-key-#{result.key}", (err, value) ->
        expect(value).to.equal(url)
        done()
