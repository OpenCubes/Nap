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
    var deferred, field, match, q, s, schema, select, value, where, _i, _len, _ref;
    deferred = Q.defer();
    q = this.model.find();
    q.limit(query.limit || 15);
    q.skip(query.limit || query.offset || 0);
    if (query.sort) {
      q.sort(query.sort);
    }
    select = "";
    if (query.select) {
      _ref = query.select.split(',');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        select += " " + s;
      }
    }
    q.select(select);
    schema = this.model.schema;
    where = _.pick(query, Object.keys(schema.paths));
    for (field in where) {
      if (!__hasProp.call(where, field)) continue;
      value = where[field];
      match = /(\W+)?(\w+)/.exec(value);
      switch (match[1]) {
        case ">":
          if (!isNaN(match[2])) {
            q.gt(field, match[2] - 0);
          }
          break;
        case ">=":
          if (!isNaN(match[2])) {
            q.gte(field, match[2] - 0);
          }
          break;
        case "<":
          if (!isNaN(match[2])) {
            q.lt(field, match[2] - 0);
          }
          break;
        case "<=":
          if (!isNaN(match[2])) {
            q.lte(field, match[2] - 0);
          }
          break;
        case "~":
          q.where(field, new RegExp(match[2], "gi"));
          break;
        case void 0:
        case "":
          q.where(field, match[2]);
      }
    }
    q.exec(function(err, result) {
      if (err) {
        return deferred.reject(err);
      }
      return deferred.resolve(result);
    });
    return deferred.promise;
  };

  Model.prototype.findById = function(id, query) {
    var deferred, q, s, select, _i, _len, _ref;
    if (query == null) {
      query = {};
    }
    deferred = Q.defer();
    q = this.model.findById(id);
    select = "";
    if (query.select) {
      _ref = query.select.split(',');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        select += " " + s;
      }
    }
    q.select(select);
    q.exec(function(err, result) {
      if (err) {
        return deferred.reject(err);
      }
      return deferred.resolve(result);
    });
    return deferred.promise;
  };

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

  Model.prototype.set = function(id, props) {
    var deferred;
    deferred = Q.defer();
    this.findById(id).then(function(obj) {
      var key, value;
      for (key in props) {
        if (!__hasProp.call(props, key)) continue;
        value = props[key];
        obj.set(key, value);
      }
      return obj.save(function(err, result) {
        if (err) {
          return deferred.reject(err);
        }
        return deferred.resolve(result);
      });
    });
    return deferred.promise;
  };

  Model.prototype["delete"] = function(id) {
    var deferred;
    deferred = Q.defer();
    this.findById(id).then(function(obj) {
      return obj.remove(function(err, result) {
        if (err) {
          return deferred.reject(err);
        }
        return deferred.resolve(result);
      });
    });
    return deferred.promise;
  };

  return Model;

})();

module.exports = Model;
