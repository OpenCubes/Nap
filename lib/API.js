var API, DEFAULTS, Provider, auth, _;

_ = require("lodash");

auth = require("./authorizations");

Provider = require("./Provider");

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
  API.prototype._stack = [];

  function API(options) {
    if (!options.mongoose || options.mongoose.constructor.name !== "Mongoose") {
      throw new Error("Expected options.mongoose to be a Mongoose instance but got " + options.mongoose);
    }
    this.options = _.assign(DEFAULTS, options);
    this.mongoose = this.options.mongoose;
  }

  API.prototype.add = function(options) {
    var model;
    model = this.mongoose.model(options.model);
    return this._stack.push(new Provider({
      model: model,
      collection: model.collection.name
    }));
  };

  API.prototype.inject = function(router) {
    var provider, _i, _len, _ref, _results;
    _ref = this._stack;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      provider = _ref[_i];
      router.get("" + this.options.domain + provider.routeBaseName, provider.index);
      router.post("" + this.options.domain + provider.routeBaseName, provider.post);
      router.get("" + this.options.domain + provider.routeBaseName + "/:id", provider.get);
      router.put("" + this.options.domain + provider.routeBaseName + "/:id", provider.put);
      router["delete"]("" + this.options.domain + provider.routeBaseName + "/:id", provider["delete"]);
      _results.push(router.get("" + this.options.domain + provider.routeBaseName + "/:id/:collection", provider.subdoc));
    }
    return _results;
  };

  return API;

})();

module.exports = API;
