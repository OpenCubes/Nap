var Provider, _;

_ = require('lodash');

Provider = (function() {
  Provider.prototype.model = "";

  Provider.prototype.collection = "";

  Provider.prototype.authorizations = {};

  Provider.prototype.authorship = "author";

  function Provider(options) {
    _.assign(this, options);
    this.routeBaseName = "/" + this.collection;
  }

  Provider.prototype.index = function(req, res, next) {};

  Provider.prototype.get = function(req, res, next) {};

  Provider.prototype.post = function(req, res, next) {};

  Provider.prototype.put = function(req, res, next) {};

  Provider.prototype["delete"] = function(req, res, next) {};

  Provider.prototype.subdoc = function(req, res, next) {};

  return Provider;

})();

module.exports = Provider;
