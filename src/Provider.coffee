_ = require 'lodash'
NapModel = require './Model'

class Provider
  model: ""
  collection: ""
  authorizations: {}
  authorship: "author"
  format: require './hypermedia-formats/bare'

  constructor: (options) ->

    _.assign @, options

    @napModel = new NapModel
      model: @model
      collection: @collection

    @routeBaseName = "/#{@collection}"

  index: (req, res, next) =>

    format = @format

    @napModel.find(req.query).then (result) ->
      res.json format(result)
    .fail next
  get: (req, res, next) =>

    format = @format

    @napModel.findById(req.params.id).then (result) ->
      res.json format(result)
    .fail next

  post: (req, res, next) =>

    format = @format
    @napModel.create(req.body).then (result) ->
      res.json format(result)
    .fail next

  put: (req, res, next) =>


    format = @format

    @napModel.set(req.params.id, req.body).then (result) ->
      res.json format(result)
    .fail next

  delete: (req, res, next) =>

    format = @format

    @napModel.delete(req.params.id).then (result) ->
      res.json format(result)
    .fail next

  subdoc: (req, res, next) =>


module.exports = Provider
