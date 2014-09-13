chai = require('chai')
should = chai.should()
chai.use(require('chai-things'))

index = require('../index')
mongoose = require("mongoose")
Model = require "../src/model"
Q = require "q"
FS = require 'q-io/fs'

nap = require('../')
user = new Model
  model: mongoose.model "User"
  collection: "users"

Story = new Model
  model: mongoose.model "Story"
  collection: "stories"
  likes: "Number"

someModel = undefined


express = require("express")
app = express()
app.get "/", (req, res) ->
  res.send "hello world"
  return
api = nap
  mongoose: mongoose
  name: "Server"
api.add
  model: 'Story'
api.inject(app, express.bodyParser)

fixtures = {}

someModel = {}

request = require('supertest')(app)

describe 'server', ->
  it 'GET / should return `hello world`', (done) ->
    request.get('/').expect('hello world').expect(200, done)


  it 'should POST fixtures to stories', (done) ->
    @timeout(5000)
    mongoose.connection.db.dropDatabase()
    FS.read('test/fixtures02.json').then (data) ->
      fixtures = JSON.parse data
      promises = []
      createObject = (collection, data) ->
        deferred = Q.defer()
        req = request.post("/api/#{collection}")
        req.send data
        req.end (err, res) ->
          if err
            return deferred.reject err
          if res.statusCode isnt 200
            return deferred.reject new Error "Status code ##{res.statusCode}"
          deferred.resolve res

        return deferred.promise



      for fixture in fixtures.stories
        promises.push createObject("stories", fixture)

      Q.allSettled promises
    .then (results) ->
      for r in results
        if r.status isnt 'fulfilled'
          return done r.reason
      done()
    .fail done

  it 'should GET stories', (done) ->
    request.get('/api/stories').end (err, res) ->

      try
        res.statusCode.toString().should.equal "200"
        res.body.should.have.length fixtures.stories.length

        for story in res.body
          should.exist story.title
          should.exist story.body
          should.exist story.likes

        someModel = res.body[0]
        done()
      catch error
        done error

  it 'should GET stories, filter and sort the via query', (done) ->

    @timeout 5000
    request.get('/api/stories?select=title&limit=2').end (err, res) ->

      try
        res.statusCode.toString().should.equal "200"
        res.body.should.have.length 2

        for story in res.body
          should.exist story.title
          should.not.exist story.body
          should.not.exist story.likes

        request.get("/api/stories?likes=>=11").end (err, res) ->
          res.statusCode.toString().should.equal "200"
          res.body.should.have.length 3

          for story in res.body
            should.exist story.title
            should.exist story.body
            should.exist story.likes
            story.likes.should.be.at.least 11

          done()
      catch error
        done error

  it 'should GET a single story', (done) ->
    request.get("/api/stories/#{someModel._id}").end (err, res) ->

      try
        res.statusCode.toString().should.equal "200"
        res.body.should.deep.equal someModel
        done()
      catch error
        done error

  it 'should PUT a story', (done) ->
    request.put("/api/stories/#{someModel._id}")
    .send(title: "Another title")
    .end (err, res) ->

      try
        res.statusCode.toString().should.equal "200"
        res.body.title.should.equal "Another title"

        request.get("/api/stories/#{someModel._id}").end (err, res) ->

          try
            res.statusCode.toString().should.equal "200"
            res.body.title.should.equal "Another title"
            done()
          catch error
            done error
      catch error
        done error

  it 'should DELETE a story', (done) ->
    request.delete("/api/stories/#{someModel._id}").end (err, res) ->

      try
        res.statusCode.toString().should.equal "200"

        request.get("/api/stories/#{someModel._id}").end (err, res) ->

          try
            res.statusCode.toString().should.equal "200"
            res.body.should.deep.equal {}
            done()
          catch error
            done error
      catch error
        done error
