Q = require 'q'
_ = require 'lodash'

class Model

  constructor: (options) ->
    _.assign @, options
    @routeBaseName = "/#{@collection}"

  find: (query, flag, id) ->

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


  findById: (oid, query={}) ->
    deferred = Q.defer()

    q = @model.findById oid

    select = ""
    if query.select then for s in query.select.split ','
      select += " #{s}"
    q.select select
    q.exec (err, result) ->
      return deferred.reject err if err
      deferred.resolve result

    deferred.promise

  create: (props, flag, id) ->
    deferred = Q.defer()
    if not flag then deferred.reject new Error(401)

    obj = new @model props
    if @authorship and id
      obj.set @authorship, id
    obj.save (err, result) ->
      if err then return deferred.reject err
      deferred.resolve result

    deferred.promise

  set: (oid, props, allow, user) ->
    deferred = Q.defer()
    @findById(oid).then (obj) =>
      if not allow
        if @authorship and obj[@authorship]?.toString() isnt user?.toString()
          return deferred.reject new Error(403)
        if not user or user.username is "guest"
          return deferred.reject new Error(401)
      if not obj then return deferred.resolve {}
      obj.set(key, value) for own key, value of props
      obj.save (err, result) ->
        if err then return deferred.reject err
        deferred.resolve result

    deferred.promise

  delete: (oid, allow, user) ->
    deferred = Q.defer()

    @findById(oid).then (obj) =>
      if not obj then return deferred.resolve {}
      if not allow
        if @authorship and obj[@authorship]?.toString() isnt user?.toString()
          return deferred.reject new Error(403)
        if not user or user.username is "guest"
          return deferred.reject new Error(401)
      obj.remove (err, result) ->
        if err then return deferred.reject err
        deferred.resolve result

    deferred.promise




module.exports = Model
