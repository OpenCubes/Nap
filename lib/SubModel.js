var Model, Q, SubModel, util, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Q = require('q');

_ = require('lodash');

Model = require('./model');

util = require('util');

SubModel = (function(_super) {
  __extends(SubModel, _super);


  /*
  optins:
    location. The fields in the parent doc that contrains subs
    link: the virtual field taht conatins the ref to parent
    paths: paths in child
   */

  function SubModel(options) {
    _.assign(this, options);
    this.routeBaseName = "/" + this.collection;
  }

  SubModel.prototype.find = function(query, flag, id) {
    var deferred, field, match, matched, mode, obj, path, pipelines, project, s, schema, select, value, w, _i, _j, _len, _len1, _ref, _ref1, _ref2;
    deferred = Q.defer();
    schema = this.model.schema;
    query.select = ((_ref = query.select) != null ? _ref.split(',') : void 0) || this.paths;
    mode = "include";
    select = [];
    _ref1 = query.select;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      s = _ref1[_i];
      if (s[0] === "-") {
        mode = "exclude";
      }
    }
    if (mode === "include") {
      select = _.intersection(this.paths, query.select);
    } else {
      query.select = query.select.map(function(value) {
        return value.substring(1);
      });
      select = _.difference(this.paths, query.select);
    }
    project = {};
    for (_j = 0, _len1 = select.length; _j < _len1; _j++) {
      path = select[_j];
      project[path] = "$" + this.location + "." + path;
    }
    project[this.link] = "$_id";
    project._id = "$" + this.location + "._id";
    match = {};
    _ref2 = _.pick(query, select);
    for (field in _ref2) {
      if (!__hasProp.call(_ref2, field)) continue;
      value = _ref2[field];
      matched = /(\W+)?(\w+)/.exec(value);
      switch (matched[1]) {
        case ">":
          if (!isNaN(matched[2])) {
            w = {};
            w["$gt"] = matched[2] - 0;
            match[field] = w;
          }
          break;
        case ">=":
          if (!isNaN(matched[2])) {
            w = {};
            w["$gte"] = matched[2] - 0;
            match[field] = w;
          }
          break;
        case "<":
          if (!isNaN(matched[2])) {
            w = {};
            w["$lt"] = matched[2] - 0;
            match[field] = w;
          }
          break;
        case "<=":
          if (!isNaN(matched[2])) {
            w = {};
            w["$lte"] = matched[2] - 0;
            match[field] = w;
          }
          break;
        case "~":
          w = {};
          w[field] = {
            $regex: matched[2],
            $options: 'gi'
          };
          match[field] = w;
          break;
        case void 0:
        case "":
          if (!isNaN(value)) {
            value = value - 0;
          }
          match[field] = value;
      }
    }
    pipelines = [
      {
        $match: {
          _id: query[this.link]
        }
      }, {
        $unwind: "$" + this.location
      }, {
        $project: project
      }, {
        $skip: query.skip || query.offset || 0
      }, {
        $limit: query.limit || 15
      }, query.sort ? {
        $sort: query.sort && query.sort[0] === '-' ? (obj = {}, obj[query.sort.substring(1)] = -1, obj) : query.sort ? (obj = {}, obj[query.sort] = 1, obj) : void 0
      } : void 0, {
        $match: match
      }
    ];
    this.model.aggregate(_.compact(pipelines), function(err, result) {
      if (err) {
        return deferred.reject(err);
      }
      return deferred.resolve(result);
    });
    return deferred.promise;
  };

  SubModel.prototype.findById = function(oid, query) {
    var deferred, q, s, select, _i, _len, _ref;
    if (query == null) {
      query = {};
    }
    deferred = Q.defer();
    q = this.model.findOne({
      "comments._id": oid
    }, {
      "comments.$": 1
    });
    select = "";
    if (query.select) {
      _ref = query.select.split(',');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        select += " comments." + s;
      }
    }
    q.select(select);
    q.exec((function(_this) {
      return function(err, result) {
        var comment;
        if (err) {
          return deferred.reject(err);
        }
        if (!result) {
          return deferred.resolve({});
        }
        comment = result.toObject().comments[0];
        comment[_this.link] = result._id;
        comment._id = comment._id.toString();
        return deferred.resolve(comment);
      };
    })(this));
    return deferred.promise;
  };

  SubModel.prototype.create = function(props, flag, id) {
    var deferred;
    deferred = Q.defer();
    if (!flag) {
      deferred.reject(new Error(401));
    } else if (!props[this.link]) {
      deferred.reject(new Error(400));
    }
    if (this.authorship) {
      props[this.authorship] = id;
    } else {
      this.model.findById(props[this.link], (function(_this) {
        return function(err, parent) {
          var obj;
          if (err) {
            return deferred.reject(err);
          }
          obj = _.pick(props, _this.paths);
          if (_this.authorship && id) {
            obj.set(_this.authorship, id);
          }
          parent[_this.location].push(props);
          return parent.save(function(err, result) {
            if (err) {
              return deferred.reject(err);
            }
            result = result.toObject();
            return deferred.resolve(result[_this.location][result[_this.location].length - 1]);
          });
        };
      })(this));
    }
    return deferred.promise;
  };

  SubModel.prototype.set = function(oid, props, allow, user) {
    var deferred, key, query, update, value;
    deferred = Q.defer();
    query = {};
    update = {};
    query["" + this.location + "._id"] = oid;
    if (this.authorship) {
      query["" + this.location + "." + this.authorship] = id;
    }
    for (key in props) {
      value = props[key];
      update["" + this.location + ".$." + key] = value;
    }
    this.model.update(query, update, (function(_this) {
      return function(err, parent) {
        if (err) {
          deferred.reject(err);
        }
        if (!allow) {
          if (_this.authorship && parent !== 1) {
            return deferred.reject(new Error(403));
          }
          if (!user || user.username === "guest") {
            return deferred.reject(new Error(401));
          }
        }
        return _this.findById(oid).then(deferred.resolve).fail(deferred.reject);
      };
    })(this));
    deferred.promise;
    return deferred.promise;
  };

  SubModel.prototype["delete"] = function(oid, allow, user) {
    var deferred, pos, query;
    deferred = Q.defer();
    query = {};
    pos = {};
    query["" + this.location + "._id"] = oid;
    if (this.authorship) {
      query["" + this.location + "." + this.authorship] = id;
    }
    pos["" + this.location + ".$"] = 1;
    this.model.findOne(query, pos, (function(_this) {
      return function(err, parent) {
        var obj, _ref;
        if (err) {
          return deferred.reject(err);
        }
        if (!parent) {
          return deferred.resolve({});
        }
        obj = parent[_this.location].id(oid);
        if (!allow) {
          if (_this.authorship && ((_ref = obj[_this.authorship]) != null ? _ref.toString() : void 0) !== (user != null ? user.toString() : void 0)) {
            return deferred.reject(new Error(403));
          }
          if (!user || user.username === "guest") {
            return deferred.reject(new Error(401));
          }
        }
        obj.remove();
        return parent.save(function(err, result) {
          if (err) {
            return deferred.reject(err);
          }
          return deferred.resolve(result);
        });
      };
    })(this));
    return deferred.promise;
  };

  return SubModel;

})(Model);

module.exports = SubModel;
