should = require('chai').should()
index = require('../index')
mongoose = require "mongoose"
mongoose.connect 'mongodb://localhost:27017/'
API = index
  mongoose: mongoose

mongoose.model 'Story', new mongoose.Schema
  title: String
  body: String

mongoose.model 'User', new mongoose.Schema
  login: String
  pwd: String


describe 'API', ->
  it 'have a `add` function', ->
    API.add.should.be.a 'function'

  it 'adds new routes to the stack', ->
    result = API.add model: 'Story'

    result.should.equal 1

    result = API.add model: 'User'

    result.should.equal 2


  it 'injects routes to the router', ->
    routes = {}

    # Creates express router mock that adds routes to previous object
    routerMock =
      get: (url, route) ->
        routes["GET #{url}"] = route
      post: (url, route) ->
        routes["POST #{url}"] = route
      delete: (url, route) ->
        routes["DELETE #{url}"] = route
      put: (url, route) ->
        routes["PUT #{url}"] = route

    API.inject routerMock

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
      "POST /api/users"
    ]

    # Check everything is ok
    for uri in expected
      if not routes[uri]
        console.log uri
      should.exist routes[uri]
      routes[uri].should.be.a 'function'

    # And no more
    Object.keys(routes).should.have.length expected.length
