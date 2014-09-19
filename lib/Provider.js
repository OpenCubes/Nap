var NapModel, Provider, Q, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ = require('lodash');

Q = require('q');

NapModel = require('./Model');

Provider = (function() {
  Provider.prototype.model = "";

  Provider.prototype.collection = "";

  Provider.prototype.authorizations = {};

  Provider.prototype.authorship = "author";

  Provider.prototype.format = require('./hypermedia-formats/bare');

  function Provider(options) {
    this.subdoc = __bind(this.subdoc, this);
    this["delete"] = __bind(this["delete"], this);
    this.put = __bind(this.put, this);
    this.post = __bind(this.post, this);
    this.get = __bind(this.get, this);
    this.index = __bind(this.index, this);
    this.checkAuth = __bind(this.checkAuth, this);
    _.assign(this, options);
    this.napModel = new NapModel({
      model: this.model,
      collection: this.collection
    });
    this.routeBaseName = "/" + this.collection;
  }

  Provider.prototype.checkAuth = function(req, res) {
    var called, deferred;
    deferred = Q.defer();
    called = false;
    (this.canThis.bind({
      config: _.pick(this, ['model', 'collection', 'authorizations', 'authorship']),
      getRole: this.getRole ? Q.denodeify(_.partial(this.getRole, req.user ? req.user._id : void 0)) : (function(_this) {
        return function() {
          deferred = Q.defer();
          deferred.resolve(req.user ? req.user.role : "");
          return deferred.promise;
        };
      })(this),
      allow: (function(_this) {
        return function() {
          if (called) {
            throw new Error("Callback called two times");
          }
          called = true;
          console.log("ALLOW");
          return deferred.resolve(true);
        };
      })(this),
      deny: (function(_this) {
        return function() {
          if (called) {
            throw new Error("Callback called two times");
          }
          console.log("DENY");
          called = true;
          return deferred.resolve(false);
        };
      })(this),
      url: req.url,
      params: req.params,
      method: req.method
    }))();
    return deferred.promise;
  };

  Provider.prototype.index = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.find(req.query, req.allow, req.user ? req.user._id : void 0).then(function(result) {
      return res.json(format(result));
    }).fail((function(_this) {
      return function(err) {
        if (!isNaN(err.message)) {
          return res.send(err.message - 0);
        } else {
          return next(err);
        }
      };
    })(this));
  };

  Provider.prototype.get = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.findById(req.params.id, req.allow, req.user ? req.user._id : void 0).then(function(result) {
      return res.json(format(result));
    }).fail((function(_this) {
      return function(err) {
        if (!isNaN(err.message)) {
          return res.send(err.message - 0);
        } else {
          return next(err);
        }
      };
    })(this));
  };

  Provider.prototype.post = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.create(req.body, req.allow, req.user ? req.user._id : void 0).then(function(result) {
      return res.json(format(result));
    }).fail((function(_this) {
      return function(err) {
        if (!isNaN(err.message)) {
          return res.send(err.message - 0);
        } else {
          return next(err);
        }
      };
    })(this));
  };

  Provider.prototype.put = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.set(req.params.id, req.body, req.allow, req.user ? req.user._id : void 0).then(function(result) {
      return res.json(format(result));
    }).fail((function(_this) {
      return function(err) {
        if (!isNaN(err.message)) {
          return res.send(err.message - 0);
        } else {
          return next(err);
        }
      };
    })(this));
  };

  Provider.prototype["delete"] = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel["delete"](req.params.id, req.allow, req.user ? req.user._id : void 0).then(function(result) {
      return res.json(format(result));
    }).fail((function(_this) {
      return function(err) {
        if (!isNaN(err.message)) {
          return res.send(err.message - 0);
        } else {
          return next(err);
        }
      };
    })(this));
  };

  Provider.prototype.subdoc = function(req, res, next) {};

  return Provider;

})();

module.exports = Provider;
