var API, DEFAULTS, Provider, auth, multipart, multipartMiddleware, _;

_ = require("lodash");

auth = require("./authorizations");

Provider = require("./Provider");

multipart = require('connect-multiparty');

multipartMiddleware = multipart();

DEFAULTS = {
  authGroups: ['guest', 'user', 'admin'],
  getRole: function(userId, callback) {
    return callback('admin');
  },
  canThis: auth.canThis,
  mongoose: void 0,
  domain: "/api"
};

API = (function() {
  function API(options) {
    if (!options.mongoose || options.mongoose.constructor.name !== "Mongoose") {
      throw new Error("Expected options.mongoose to be a Mongoose instance but got " + options.mongoose);
    }
    this.options = _.assign(DEFAULTS, options);
    this.mongoose = this.options.mongoose;
    this._stack = [];
  }

  API.prototype.add = function(options) {
    var model;
    model = this.mongoose.model(options.model);
    return this._stack.push(new Provider({
      model: model,
      collection: model.collection.name
    }));
  };

  API.prototype.inject = function(app, bodyParser) {
    var provider, _i, _len, _ref, _results;
    _ref = this._stack;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      provider = _ref[_i];
      app.get("" + this.options.domain + provider.routeBaseName, provider.index);
      app.post("" + this.options.domain + provider.routeBaseName, bodyParser(), provider.post);
      app.get("" + this.options.domain + provider.routeBaseName + "/:id", provider.get);
      app.put("" + this.options.domain + provider.routeBaseName + "/:id", bodyParser(), provider.put);
      app["delete"]("" + this.options.domain + provider.routeBaseName + "/:id", provider["delete"]);
      _results.push(app.get("" + this.options.domain + provider.routeBaseName + "/:id/:collection", provider.subdoc));
    }
    return _results;
  };

  return API;

})();

module.exports = API;
