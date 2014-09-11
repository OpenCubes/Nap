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

    query = @model.find()
    .limit query.limit or 15
    .skip query.limit or query.offset or 0
    .select (("#{selection}" for selection in query.select.split(',')).join ' ' if query.select)
    .populate ("#{populate}" for populate in query.populate.split(',')).join ' '
    .sort query.sort

    schema = model.schema

    where = _.pick query, Object.keys(schema.path)
    for own field, value of where
      match = /(\W+)(\w+)/.exec value
      switch match[1]
        when ">"
          if typeof match[2] is "number"
            query.gt field, match[2] - 0
        when ">="
          if typeof match[2] is "number"
            query.gte field, match[2] - 0
        when "<"
          if typeof match[2] is "number"
            query.lt field, match[2] - 0
        when "<="
          if typeof match[2] is "number"
            query.lte field, match[2] - 0

        when "~"
          if typeof match[2] is "number"
            query.where field, new RegExp(match[2], "gi")

      query.exec (err, result) ->
        return deferred.reject(err) if err
        deferred.resolve result

    deferred.promise




  findById: (id) ->
  create: (props) ->
    deferred = Q.defer()

    obj = new @model props
    obj.save (err, result) ->
      if err then return deferred.reject err
      deferred.resolve result

    deferred.promise

  set: (props) ->

  delete: (id) ->



module.exports = Model
