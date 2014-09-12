Q = require 'q'
_ = require 'lodash'

class Model
  model: undefined
  collection: ""
  authorizations: {}
  authorship: "author"

  constructor: (options) ->
    _.assign @, options
    @routeBaseName = "/#{@collection}"

  find: (query) ->
    deferred = Q.defer()

    q = @model.find()
    q.limit query.limit or 15
    q.skip query.limit or query.offset or 0
    if query.sort then q.sort query.sort

    select = ""
    if query.select then for s in query.select.split ','
      select += " #{s}"
    q.select select
    #if query.populate then q.populate ("#{populate}" for populate in query.populate.split(',')).join ' '


    schema = @model.schema

    where = _.pick query, Object.keys(schema.paths)


    for own field, value of where
      match = /(\W+)?(\w+)/.exec value
      switch match[1]

        when ">"
          if not isNaN match[2]
            q.gt field, match[2] - 0

        when ">="
          if not isNaN match[2]
            q.gte field, match[2] - 0

        when "<"
          if not isNaN match[2]
            q.lt field, match[2] - 0

        when "<="
          if not isNaN match[2]
            q.lte field, match[2] - 0

        when "~"
          q.where field, new RegExp(match[2], "gi")

        when undefined, "" # =
          q.where field, match[2]

    q.exec (err, result) ->
      return deferred.reject(err) if err
      deferred.resolve result

    deferred.promise


  findById: (id, query={}) ->
    deferred = Q.defer()

    q = @model.findById id

    select = ""
    if query.select then for s in query.select.split ','
      select += " #{s}"
    q.select select
    q.exec (err, result) ->
      return deferred.reject err if err
      deferred.resolve result

    deferred.promise

  create: (props) ->
    deferred = Q.defer()

    obj = new @model props
    obj.save (err, result) ->
      if err then return deferred.reject err
      deferred.resolve result

    deferred.promise

  set: (id, props) ->
    deferred = Q.defer()

    @findById(id).then (obj) ->
      obj.set(key, value) for own key, value of props
      obj.save (err, result) ->
        if err then return deferred.reject err
        deferred.resolve result

    deferred.promise

  delete: (id) ->
    deferred = Q.defer()

    @findById(id).then (obj) ->
      obj.remove (err, result) ->
        if err then return deferred.reject err
        deferred.resolve result

    deferred.promise




module.exports = Model
