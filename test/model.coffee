chai = require('chai')
should = chai.should()
chai.use(require('chai-things'))

index = require('../index')
mongoose = require("mongoose-q")()
Model = require "../src/model"
Q = require "q"
user = new Model
  model: mongoose.model "User"
  collection: "users"

Story = new Model
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
        promises.push Story.create fixture

      Q.allSettled promises
    .then ->
      done()
    .fail done

  describe "#find()", ->

    it 'supports no parameter', (done) ->
      Story.find({}).then (stories) ->
        stories.should.have.length 12
        done()

    it 'supports `sort` parameter', (done) ->
      Story.find(sort: "likes").then (stories)->
        oldLikeCount = 0
        for s in stories
          oldLikeCount.should.be.at.most s.likes
          oldLikeCount = s.likes
        done()
      .fail done

    it 'supports `limit` parameter', (done) ->
      Story.find(limit: 3).then (stories)->
        stories.should.have.length 3
        done()
      .fail done

    it 'supports `skip` parameter', (done) ->
      Story.find(offset: 3).then (stories)->
        stories.should.have.length 9
        done()
      .fail done

    it 'supports `select` parameter', (done) ->
      Story.find(select: 'likes').then (stories)->
        stories.should.have.length 12
        for s in stories
          should.not.exist s.title
          should.not.exist s.body
          should.exist s.likes
        Story.find(select: '-likes')
      .then (stories)->
        stories.should.have.length 12
        for s in stories
          should.exist s.title
          should.exist s.body
          should.not.exist s.likes
        done()
      .fail done

    describe 'where', ->

      it 'supports `=`', (done) ->
        Story.find(likes: '7').then (stories)->
          stories.should.have.length 2
          stories.should.all.have.property 'likes', 7
          done()
        .fail done



      it 'supports `<`', (done) ->
        Story.find(likes: '<7').then (stories)->
          stories.should.have.length 2

          for story in stories
            story.likes.should.be.below 7
          done()
        .fail done

      it 'supports `<=`', (done) ->
        Story.find(likes: '<=7').then (stories)->
          stories.should.have.length 4

          for story in stories
            story.likes.should.be.most 7
          done()
        .fail done

      it 'supports `>`', (done) ->
        Story.find(likes: '>7').then (stories)->
          stories.should.have.length 8

          for story in stories
            story.likes.should.be.above 7
          done()
        .fail done

      it 'supports `>=`', (done) ->
        Story.find(likes: '>=7').then (stories)->
          stories.should.have.length 10

          for story in stories
            story.likes.should.be.least 7
          done()
        .fail done
