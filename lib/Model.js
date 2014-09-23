var Model, Q, _,
  __hasProp = {}.hasOwnProperty;

Q = require('q');

_ = require('lodash');

Model = (function() {
  function Model(options) {
    _.assign(this, options);
    this.routeBaseName = "/" + this.collection;
  }

  Model.prototype.find = function(query, flag, id) {
    var deferred, field, match, q, s, schema, select, value, where, _i, _len, _ref;
    if (query == null) {
      query = {};
    }
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

  Model.prototype.findById = function(oid, query) {
    var deferred, q, s, select, _i, _len, _ref;
    if (query == null) {
      query = {};
    }
    deferred = Q.defer();
    q = this.model.findById(oid);
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

  Model.prototype.create = function(props, flag, id) {
    var deferred, obj;
    deferred = Q.defer();
    if (!flag) {
      deferred.reject(new Error(401));
    }
    obj = new this.model(props);
    if (this.authorship && id) {
      obj.set(this.authorship, id);
    }
    obj.save(function(err, result) {
      if (err) {
        return deferred.reject(err);
      }
      return deferred.resolve(result);
    });
    return deferred.promise;
  };

  Model.prototype.set = function(oid, props, allow, user) {
    var deferred;
    deferred = Q.defer();
    this.findById(oid).then((function(_this) {
      return function(obj) {
        var key, value, _ref;
        if (!allow) {
          if (_this.authorship && ((_ref = obj[_this.authorship]) != null ? _ref.toString() : void 0) !== (user != null ? user.toString() : void 0)) {
            return deferred.reject(new Error(403));
          }
          if (!user || user.username === "guest") {
            return deferred.reject(new Error(401));
          }
        }
        if (!obj) {
          return deferred.resolve({});
        }
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
      };
    })(this));
    return deferred.promise;
  };

  Model.prototype["delete"] = function(oid, allow, user) {
    var deferred;
    deferred = Q.defer();
    this.findById(oid).then((function(_this) {
      return function(obj) {
        var _ref;
        if (!obj) {
          return deferred.resolve({});
        }
        if (!allow) {
          if (_this.authorship && ((_ref = obj[_this.authorship]) != null ? _ref.toString() : void 0) !== (user != null ? user.toString() : void 0)) {
            return deferred.reject(new Error(403));
          }
          if (!user || user.username === "guest") {
            return deferred.reject(new Error(401));
          }
        }
        return obj.remove(function(err, result) {
          if (err) {
            return deferred.reject(err);
          }
          return deferred.resolve(result);
        });
      };
    })(this));
    return deferred.promise;
  };

  return Model;

})();

module.exports = Model;
