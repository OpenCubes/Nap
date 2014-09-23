Q = require 'q'
_ = require 'lodash'
Model = require './model'
util = require('util')
class SubModel extends Model

  ###
  optins:
    location. The fields in the parent doc that contrains subs
    link: the virtual field taht conatins the ref to parent
    paths: paths in child
  ###

  constructor: (options) ->
    _.assign @, options
    @routeBaseName = "/#{@collection}"

  find: (query, flag, id) ->
    deferred = Q.defer()

    #if query.populate then q.populate ("#{populate}" for populate in query.populate.split(',')).join ' '

    schema = @model.schema
    query.select = query.select?.split(',') or @paths
    mode = "include"
    select = []
    for s in query.select
      if s[0] is "-" then mode = "exclude"

    if mode is "include"
      select = _.intersection @paths, query.select
    else
      query.select = query.select.map (value) -> value.substring 1
      select = _.difference @paths, query.select



    project = {}
    for path in select
      project[path] = "$#{@location}.#{path}"
    project[@link] = "$_id"
    project._id = "$#{@location}._id"

    match = {}
    for own field, value of _.pick query, select
      matched = /(\W+)?(\w+)/.exec value
      switch matched[1]

        when ">"
          if not isNaN matched[2]
            w = {}
            w["$gt"] = matched[2] - 0
            match[field] = w
        when ">="
          if not isNaN matched[2]
            w = {}
            w["$gte"] = matched[2] - 0
            match[field] = w
        when "<"
          if not isNaN matched[2]
            w = {}
            w["$lt"] = matched[2] - 0
            match[field] = w
        when "<="
          if not isNaN matched[2]
            w = {}
            w["$lte"] = matched[2] - 0
            match[field] = w
        when "~"
          w = {}
          w[field] = { $regex: matched[2], $options: 'gi' }
          match[field] = w

        when undefined, "" # =
          if not isNaN value then value = value - 0
          match[field] = value
    pipelines = [ # Use lodash compact to remove any undefined value
      {
        $match: {_id: query[@link]}
      },
      {
        $unwind: "$#{@location}"
      },
      {
        $project: project
      },
      {
        $skip: query.skip or query.offset or 0
      },
      {
        $limit: query.limit or 15
      },
      if query.sort then {
        $sort: if query.sort and query.sort[0] is '-'
          obj = {}
          obj[query.sort.substring(1)] = -1
          obj
        else if query.sort
          obj = {}
          obj[query.sort] = 1
          obj
      },
      {
        $match: match
      }
    ]

    # console.log(util.inspect(pipelines, showHidden: false, depth: null, color: true))

    @model.aggregate _.compact(pipelines), (err, result) ->
      if err then return deferred.reject err
      deferred.resolve result
    deferred.promise


  findById: (oid, query={}) ->
    deferred = Q.defer()
    q = @model.findOne {"comments._id": oid}, {"comments.$": 1}

    select = ""
    if query.select then for s in query.select.split ','
      select += " comments.#{s}"
    q.select select
    q.exec (err, result) =>

      return deferred.reject err if err
      if not result then return deferred.resolve {}
      comment = result.toObject().comments[0]
      comment[@link] = result._id

      comment._id = comment._id.toString()
      deferred.resolve comment

    deferred.promise

  create: (props, flag, id) ->
    deferred = Q.defer()
    if not flag then deferred.reject new Error(401)
    else if not props[@link] then deferred.reject new Error(400)
    if @authorship then props[@authorship] = id
    else
      @model.findById props[@link], (err, parent) =>
        if err then return deferred.reject err
        obj = _.pick props, @paths
        if @authorship and id
          obj.set @authorship, id
        parent[@location].push props
        parent.save (err, result) =>

          if err then return deferred.reject err

          result = result.toObject()
          deferred.resolve result[@location][result[@location].length - 1]

    deferred.promise

  set: (oid, props, allow, user) ->
    deferred = Q.defer()
    query = {}
    update = {}
    query["#{@location}._id"] = oid
    query["#{@location}.#{@authorship}"] = id if @authorship
    update["#{@location}.$.#{key}"] = value for key, value of props
    @model.update query, update, (err, parent) =>
      if err then deferred.reject err
      if not allow
        if @authorship and parent isnt 1
          return deferred.reject new Error(403)
        if not user or user.username is "guest"
          return deferred.reject new Error(401)
      @findById(oid).then(deferred.resolve).fail(deferred.reject)
    deferred.promise



    deferred.promise

  delete: (oid, allow, user) ->
    deferred = Q.defer()
    query = {}
    pos = {}
    query["#{@location}._id"] = oid
    query["#{@location}.#{@authorship}"] = id if @authorship
    pos["#{@location}.$"] = 1
    @model.findOne query, pos, (err, parent) =>
      if err then return deferred.reject err
      if not parent then return deferred.resolve {}
      obj = parent[@location].id oid
      if not allow
        if @authorship and obj[@authorship]?.toString() isnt user?.toString()
          return deferred.reject new Error(403)
        if not user or user.username is "guest"
          return deferred.reject new Error(401)
      obj.remove()
      parent.save (err, result) ->
        if err then return deferred.reject err
        deferred.resolve result

    deferred.promise




module.exports = SubModel
