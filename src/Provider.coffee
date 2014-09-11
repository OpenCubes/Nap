_ = require 'lodash'

class Provider
  model: ""
  collection: ""
  authorizations: {}
  authorship: "author"

  constructor: (options) ->
    _.assign @, options
    @routeBaseName = "/#{@collection}"

  index: (req, res, next) ->

  get: (req, res, next) ->

  post: (req, res, next) ->

  put: (req, res, next) ->

  delete: (req, res, next) ->

  subdoc: (req, res, next) ->


module.exports = Provider
