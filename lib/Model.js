var Model, Q, _,
  __hasProp = {}.hasOwnProperty;

Q = require('q');

_ = require('lodash');

Model = (function() {
  Model.prototype.model = void 0;

  Model.prototype.collection = "";

  Model.prototype.authorizations = {};

  Model.prototype.authorship = "author";

  function Model(options) {
    _.assign(this, options);
    this.routeBaseName = "/" + this.collection;
  }

  Model.prototype.find = function(query) {
    var deferred, field, match, populate, schema, selection, value, where;
    deferred = Q.defer();
    query = this.model.find().limit(query.limit || 15).skip(query.limit || query.offset || 0).select((query.select ? ((function() {
      var _i, _len, _ref, _results;
      _ref = query.select.split(',');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        selection = _ref[_i];
        _results.push("" + selection);
      }
      return _results;
    })()).join(' ') : void 0)).populate(((function() {
      var _i, _len, _ref, _results;
      _ref = query.populate.split(',');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        populate = _ref[_i];
        _results.push("" + populate);
      }
      return _results;
    })()).join(' ')).sort(query.sort);
    schema = model.schema;
    where = _.pick(query, Object.keys(schema.path));
    for (field in where) {
      if (!__hasProp.call(where, field)) continue;
      value = where[field];
      match = /(\W+)(\w+)/.exec(value);
      switch (match[1]) {
        case ">":
          if (typeof match[2] === "number") {
            query.gt(field, match[2] - 0);
          }
          break;
        case ">=":
          if (typeof match[2] === "number") {
            query.gte(field, match[2] - 0);
          }
          break;
        case "<":
          if (typeof match[2] === "number") {
            query.lt(field, match[2] - 0);
          }
          break;
        case "<=":
          if (typeof match[2] === "number") {
            query.lte(field, match[2] - 0);
          }
          break;
        case "~":
          if (typeof match[2] === "number") {
            query.where(field, new RegExp(match[2], "gi"));
          }
      }
      query.exec(function(err, result) {
        if (err) {
          return deferred.reject(err);
        }
        return deferred.resolve(result);
      });
    }
    return deferred.promise;
  };

  Model.prototype.findById = function(id) {};

  Model.prototype.create = function(props) {
    var deferred, obj;
    deferred = Q.defer();
    obj = new this.model(props);
    obj.save(function(err, result) {
      if (err) {
        return deferred.reject(err);
      }
      return deferred.resolve(result);
    });
    return deferred.promise;
  };

  Model.prototype.set = function(props) {};

  Model.prototype["delete"] = function(id) {};

  return Model;

})();

module.exports = Model;
