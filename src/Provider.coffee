_ = require 'lodash'
Q = require 'q'
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
      authorship: @authorship

    @routeBaseName = "/#{@collection}"

  checkAuth: (req, res) =>
    deferred = Q.defer()
    called = false

    (@canThis.bind
      config: _.pick @, ['model', 'collection', 'authorizations', 'authorship']
      getRole: if @getRole then Q.denodeify(_.partial(@getRole, if req.user then req.user._id)) else =>
        deferred = Q.defer()
        deferred.resolve if req.user then req.user.role else ""
        deferred.promise
      allow: =>
        if called
          throw new Error "Callback called two times"
        called = true
        console.log "ALLOW"
        deferred.resolve true
      deny: =>
        if called
          throw new Error "Callback called two times"
        console.log "DENY"
        called = true
        deferred.resolve false
      url: req.url
      params: req.params
      method: req.method)()

    deferred.promise



  index: (req, res, next) =>
    format = @format

    @napModel.find(req.query, req.allow, if req.user then req.user._id).then (result) ->
      res.json format(result)
    .fail (err) =>
      if not isNaN err.message
        res.send err.message - 0
      else next err

  get: (req, res, next) =>

    format = @format

    @napModel.findById(req.params.id, req.allow, if req.user then req.user._id).then (result) ->
      res.json format(result)
    .fail (err) =>
      if not isNaN err.message
        res.send err.message - 0
      else next err

  post: (req, res, next) =>

    format = @format

    @napModel.create(req.body, req.allow, if req.user then req.user._id).then (result) ->
      res.json format(result)
    .fail (err) =>
      if not isNaN err.message
        res.send err.message - 0
      else next err

  put: (req, res, next) =>


    format = @format

    @napModel.set(req.params.id, req.body, req.allow, if req.user then req.user._id).then (result) ->
      res.json format(result)
    .fail (err) =>
      if not isNaN err.message
        res.send err.message - 0
      else next err

  delete: (req, res, next) =>

    format = @format


    @napModel.delete(req.params.id, req.allow, if req.user then req.user._id).then (result) ->
      res.json format(result)
    .fail (err) =>
      if not isNaN err.message
        res.send err.message - 0
      else next err

  subdoc: (req, res, next) =>


module.exports = Provider
