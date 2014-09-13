var NapModel, Provider, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ = require('lodash');

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
    _.assign(this, options);
    this.napModel = new NapModel({
      model: this.model,
      collection: this.collection
    });
    this.routeBaseName = "/" + this.collection;
  }

  Provider.prototype.index = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.find(req.query).then(function(result) {
      return res.json(format(result));
    }).fail(next);
  };

  Provider.prototype.get = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.findById(req.params.id).then(function(result) {
      return res.json(format(result));
    }).fail(next);
  };

  Provider.prototype.post = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.create(req.body).then(function(result) {
      return res.json(format(result));
    }).fail(next);
  };

  Provider.prototype.put = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel.set(req.params.id, req.body).then(function(result) {
      return res.json(format(result));
    }).fail(next);
  };

  Provider.prototype["delete"] = function(req, res, next) {
    var format;
    format = this.format;
    return this.napModel["delete"](req.params.id).then(function(result) {
      return res.json(format(result));
    }).fail(next);
  };

  Provider.prototype.subdoc = function(req, res, next) {};

  return Provider;

})();

module.exports = Provider;
