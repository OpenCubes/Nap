should = require('chai').should()
index = require('../index')
mongoose = require("mongoose-q")()
Model = require "../src/model"
Q = require "q"
user = new Model
  model: mongoose.model "User"
  collection: "users"

story = new Model
  model: mongoose.model "Story"
  collection: "stories"
  likes: "Number"

mongoose.connection.collections.users.drop ->
mongoose.connection.collections.stories.drop ->

FS = require("q-io/fs")

describe 'Model', ->
  it 'is a constructor ', ->
    Model.should.be.a 'function'

  it 'can mount fixtures', (done) ->
    FS.read('test/fixtures.json').then (data) ->
      fixtures = JSON.parse data
      promises = []

      for fixture in fixtures.users
        promises.push user.create fixture

      for fixture in fixtures.stories
        promises.push story.create fixture

      Q.allSettled promises
    .then ->
      done()
    .fail done
