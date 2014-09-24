_ = require "lodash"

auth = require "./authorizations"
Provider = require "./Provider"
multipart = require('connect-multiparty')
multipartMiddleware = multipart()

DEFAULTS =
  authGroups: ['guest', 'user', 'admin']
  mongoose: undefined
  authorship: "author"
  domain: "/api"

class API


  constructor: (options) ->
    if not options.mongoose or options.mongoose.constructor.name isnt "Mongoose"
      throw new Error("Expected options.mongoose to be a Mongoose
        instance but got #{options.mongoose}")

    @options = _.assign DEFAULTS, options

    @mongoose = @options.mongoose

    @_stack = []

  add: (options) =>
    model = @mongoose.model options.model
    @_stack.push new Provider(
      model: model
      collection: model.collection.name
      authorship: options.authorship
    )
    for sub in (options.submodels or [])
      @_stack.push new Provider(
        model: model
        collection: sub
        authorship: options.authorship
        submodel: true
        location: sub
        link: options.model.toLowerCase()
        paths: Object.keys(model?.schema?.paths[sub]?.schema?.paths or {})

      )
    @_stack.length

  inject: (app, bodyParser, login, canThis=(req, res, next)->next()) ->
    for provider in @_stack

      app.get      "#{@options.domain}#{provider.routeBaseName}", login, canThis, provider.index

      app.post     "#{@options.domain}#{provider.routeBaseName}", login, canThis, bodyParser(), provider.post

      app.get      "#{@options.domain}#{provider.routeBaseName}/:id", login, canThis, provider.get

      app.put      "#{@options.domain}#{provider.routeBaseName}/:id", login, canThis, bodyParser(), provider.put

      app.delete   "#{@options.domain}#{provider.routeBaseName}/:id", login, canThis, provider.delete

      app.get      "#{@options.domain}#{provider.routeBaseName}/:id/:collection",
        login, canThis, provider.subdoc

module.exports = API
