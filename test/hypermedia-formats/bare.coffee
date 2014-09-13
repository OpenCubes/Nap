bare = require '../../lib/hypermedia-formats/bare'
should = require('chai').should()

describe 'bare hypermedia formatter', ->
  it 'should return json data bare', ->
    houses =
      lannister: ['Tywin', 'Cersei', 'Tyrion', 'Jaimie']
      baratheon: ['Robert', 'Renly', 'Stannis']
      stark: ['Ned', 'Catelyn', 'Sansa', 'Robb', 'Bran', 'Rickon']

    bare(houses).should.deep.equal houses
