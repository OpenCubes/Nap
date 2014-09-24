should = require('chai').should()
index = require('../index')
mongoose = require "mongoose"
mongoose.connect 'mongodb://localhost:27017/'
API = index
  mongoose: mongoose
  name: "APITest"

mongoose.model 'User', new mongoose.Schema
  login: String
  pwd: String


mongoose.model 'Story', new mongoose.Schema
  title: String
  body: String
  likes: Number
  comments: {foo: String, bar: String}
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }

describe 'API', ->
  it 'have a `add` function', ->
    API.add.should.be.a 'function'

  it 'should add new routes to the stack', ->
    result = API.add model: 'Story', submodels: ['comments']

    result.should.equal 2

    result = API.add model: 'User'

    result.should.equal 3


  it 'should inject routes to the router', ->
    routes = {}

    # Creates express router mock that adds routes to previous object
    routerMock =
      get: (url, mw2, mw3, route) ->
        routes["GET #{url}"] = route
      post: (url, mw, mw2, mw3, route) ->
        routes["POST #{url}"] = route
      delete: (url, mw2, mw3, route) ->
        routes["DELETE #{url}"] = route
      put: (url, mw, mw2, mw3, route) ->
        routes["PUT #{url}"] = route

    API.inject routerMock, ->

    # These are the routes that should be generated
    expected = [
      "GET /api/stories",
      "GET /api/stories/:id",
      "GET /api/stories/:id/:collection",
      "PUT /api/stories/:id",
      "DELETE /api/stories/:id"
      "POST /api/stories",

      "GET /api/users",
      "GET /api/users/:id",
      "GET /api/users/:id/:collection",
      "PUT /api/users/:id",
      "DELETE /api/users/:id"
      "POST /api/users",

      "GET /api/comments",
      "GET /api/comments/:id",
      "GET /api/comments/:id/:collection",
      "PUT /api/comments/:id",
      "DELETE /api/comments/:id"
      "POST /api/comments"
    ]

    # Check everything is ok
    for uri in expected
      if not routes[uri]
        console.log uri
      should.exist routes[uri]
      routes[uri].should.be.a 'function'

    # And no more
    Object.keys(routes).should.have.length expected.length
