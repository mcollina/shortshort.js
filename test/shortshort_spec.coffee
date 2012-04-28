expect = require('chai').expect
sinon = require('sinon')

shortshort = require '../src/shortshort'

describe "shortshort", ->

  it "should have a myfunc that returns hello world", ->
    expect(shortshort.myfunc()).to.equal("hello world")
