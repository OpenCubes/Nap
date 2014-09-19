chai = require('chai')
should = chai.should()
chai.use(require('chai-things'))
index = require('../index')
mongoose = require("mongoose")
Model = require "../src/model"
Q = require "q"
FS = require 'q-io/fs'

nap = require('../')



passport = require 'passport'
BasicStrategy = require('passport-http').BasicStrategy

passport.use new BasicStrategy((username, pwd, done) ->

  if pwd is "1234" and username is "Foo"
    return done undefined, {
      username: "Foo"
      role: "admin"
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

#app.use express.logger()

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
  authorizations:
    get: 'guest'
    post: 'user'
    put: 'admin'
    delete: 'admin'

api.inject app, express.bodyParser, passport.authenticate("basic", session: false), (req, res, next) ->
  req.allow = switch req.method
    when "get" then true
    when "post" then if req.user and req.user.username is "Foo" then false
    when "put", "delete" then false

  next()

token = 'Basic Rm9vOjEyMzQ='
request = require('supertest')(app)
aStory = {}

describe 'authorizations', ->
  it 'should connect the server with passport', (done) ->
     request.get('/').set('Authorization', token).end (err, res) ->
       res.body.should.deep.equal username: 'Foo', role: 'admin'
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
