_ = require "lodash"

auth = require "./authorizations"
Provider = require "./Provider"

DEFAULTS =
  authGroups: ['guest', 'user', 'admin']
  getRole: (userId, callback) -> callback 'admin'
  canThis: auth.canThis
  mongoose: undefined
  domain: "/api"

class API

  _stack: []

  constructor: (options) ->

    if not options.mongoose or options.mongoose.constructor.name isnt "Mongoose"
      throw new Error("Expected options.mongoose to be a Mongoose
        instance but got #{options.mongoose}")

    @options = _.assign DEFAULTS, options

    @mongoose = @options.mongoose

  add: (options) ->
    model = @mongoose.model options.model

    @_stack.push new Provider(model: model, collection: model.collection.name)

  inject: (router) ->

    for provider in @_stack

      router.get      "#{@options.domain}#{provider.routeBaseName}", provider.index

      router.post     "#{@options.domain}#{provider.routeBaseName}", provider.post



      router.get      "#{@options.domain}#{provider.routeBaseName}/:id", provider.get

      router.put      "#{@options.domain}#{provider.routeBaseName}/:id", provider.put

      router.delete   "#{@options.domain}#{provider.routeBaseName}/:id", provider.delete

      router.get      "#{@options.domain}#{provider.routeBaseName}/:id/:collection",
        provider.subdoc

module.exports = API
