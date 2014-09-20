chai = require('chai')
should = chai.should()
chai.use(require('chai-things'))
index = require('../index')
mongoose = require("mongoose")
Model = require "../src/model"
Q = require "q"
FS = require 'q-io/fs'

nap = require('../')
someUser = {}
otherUser = {}



passport = require 'passport'
BasicStrategy = require('passport-http').BasicStrategy

passport.use new BasicStrategy((username, pwd, done) ->
  if pwd is "1234" and username is "Foo"
    return done undefined, {
      username: "Foo"
      role: "admin"
      _id: someUser._id
    }
  if pwd is "password" and username is "username"
    return done undefined, {
      username: "username"
      role: "user"
      _id: otherUser._id
    }
  if pwd is "guest" and username is "guest"
    done undefined, {
      username: "guest",
      role: "guest"
    }
  else done()
)



express = require("express")
app = express()

# app.use express.logger()

app.use (req, res, next) ->
  req.headers['authorization'] = "Basic Z3Vlc3Q6Z3Vlc3Q=" unless req.headers['authorization']
  next()

# Initialize Passport! Note: no need to use session middleware when each
# request carries authentication credentials, as is the case with HTTP Basic.

app.use passport.initialize()


app.get '/', passport.authenticate("basic", session: false), (req, res) -> res.send req.user

api = nap
  mongoose: mongoose
api.add
  model: 'Story'
  authorship: "author"
  authorizations:
    get: 'guest'
    post: 'user'
    put: 'admin'
    delete: 'admin'

api.inject app, express.bodyParser, passport.authenticate("basic", session: false), (req, res, next) ->
  req.allow = switch req.method
    when "GET" then true
    when "POST" then if req.user and req.user.role isnt "guest" then true
    when "PUT", "DELETE" then false

  next()

fooToken = 'Basic Rm9vOjEyMzQ='
request = require('supertest')(app)
aStory = {}
otherStory = {}

describe 'authorizations', ->
  before (done) ->
    User = mongoose.model "User"
    user = new User login: "Foo", role: "admin"
    user.save (err, user) ->
      someUser = user
      user = new User login: "username", role: "user"
      user.save (err, user) ->
        otherUser = user
        done()
  it 'should connect the server with passport', (done) ->
     request.get('/').set('Authorization', fooToken).end (err, res) ->
       res.body.should.deep.equal username: 'Foo', role: 'admin', _id: someUser._id.toString()
       done()
  describe 'guests', ->
    it 'should have access to stories', (done) ->
      request.get('/api/stories').end (err, res) ->
        res.body.should.have.length 7
        aStory = res.body[0]

        done()

    it 'should have access to one story', (done) ->
      request.get("/api/stories/#{aStory._id}").end (err, res) ->
        res.body.should.deep.equal aStory
        done()

    it 'should not be able to post mod', (done) ->
      req = request.post("/api/stories")
      req.send title: "This is a title", body: "This is a bodty"
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 401
          done()
        catch err
          done err

    it 'should not be able to put mod', (done) ->
      req = request.put("/api/stories/#{aStory._id}")
      req.send title: "This is a title", body: "This is a bodty"
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 401
          request.get("/api/stories/#{aStory._id}").end (err, res) ->
            res.body.should.deep.equal aStory
            done()

        catch err
          done err

    it 'should not be able to delete mod', (done) ->
      req = request.delete("/api/stories/#{aStory._id}")
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 401
          request.get("/api/stories/#{aStory._id}").end (err, res) ->
            res.body.should.deep.equal aStory
            done()

        catch err
          done err
  describe 'users', ->
    token = "Basic dXNlcm5hbWU6cGFzc3dvcmQ=" # username:password
    it 'should be able to post a mod', (done) ->
      req = request.post("/api/stories")
      req.set 'Authorization', token
      req.send title: "This is a title", body: "This is a bodty"
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 200
          otherStory = res.body
          done()
        catch err
          done err

    it 'should be able to put his mod', (done) ->
      req = request.put("/api/stories/#{otherStory._id}")
      req.set 'Authorization', token
      req.send title: "This is another title"
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 200
          res.body.title.should.equal "This is another title"
          done()
        catch err
          done err

    it 'shouldn\'t be able to put one\'s mod', (done) ->
      req = request.put("/api/stories/#{otherStory._id}")
      req.set 'Authorization', fooToken
      req.send title: "This is not another title"
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 403
          request.get("/api/stories/#{otherStory._id}").end (err, res) ->
            if err then done err

            res.body.title.should.equal "This is another title"
            done()
        catch err
          done err

    it 'shouldn\'t be able to delete one\'s mod', (done) ->
      req = request.delete("/api/stories/#{otherStory._id}")
      req.set 'Authorization', fooToken
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 403
          request.get("/api/stories/#{otherStory._id}").end (err, res) ->
            if err then done err

            res.body.title.should.equal "This is another title"
            done()
        catch err
          done err

    it 'should be able to delete his mod', (done) ->
      req = request.delete("/api/stories/#{otherStory._id}")
      req.set 'Authorization', token
      req.end (err, res) ->
        try
          if err then return done err
          res.statusCode.should.equal 200
          request.get("/api/stories/#{otherStory._id}").end (err, res) ->
            if err then done err
            res.body.should.deep.equal {}
            done()
        catch err
          done err
