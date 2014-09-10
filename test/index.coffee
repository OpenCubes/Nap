should = require('chai').should()
scapegoat = require('../index')

describe 'module', ->
  it 'returns a function', ->
    scapegoat.should.be.a 'function'
