var API, DEFAULTS, Provider, auth, multipart, multipartMiddleware, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ = require("lodash");

auth = require("./authorizations");

Provider = require("./Provider");

multipart = require('connect-multiparty');

multipartMiddleware = multipart();

DEFAULTS = {
  authGroups: ['guest', 'user', 'admin'],
  mongoose: void 0,
  authorship: "author",
  domain: "/api"
};

API = (function() {
  function API(options) {
    this.add = __bind(this.add, this);
    if (!options.mongoose || options.mongoose.constructor.name !== "Mongoose") {
      throw new Error("Expected options.mongoose to be a Mongoose instance but got " + options.mongoose);
    }
    this.options = _.assign(DEFAULTS, options);
    this.mongoose = this.options.mongoose;
    this._stack = [];
  }

  API.prototype.add = function(options) {
    var model, sub, _i, _len, _ref, _ref1, _ref2, _ref3;
    model = this.mongoose.model(options.model);
    this._stack.push(new Provider({
      model: model,
      collection: model.collection.name,
      authorship: options.authorship
    }));
    _ref = options.submodels || [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sub = _ref[_i];
      this._stack.push(new Provider({
        model: model,
        collection: sub,
        authorship: options.authorship,
        submodel: true,
        location: sub,
        link: options.model.toLowerCase(),
        paths: Object.keys((model != null ? (_ref1 = model.schema) != null ? (_ref2 = _ref1.paths[sub]) != null ? (_ref3 = _ref2.schema) != null ? _ref3.paths : void 0 : void 0 : void 0 : void 0) || {})
      }));
    }
    return this._stack.length;
  };

  API.prototype.inject = function(app, bodyParser, login, canThis) {
    var provider, _i, _len, _ref, _results;
    if (canThis == null) {
      canThis = function(req, res, next) {
        return next();
      };
    }
    _ref = this._stack;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      provider = _ref[_i];
      app.get("" + this.options.domain + provider.routeBaseName, login, canThis, provider.index);
      app.post("" + this.options.domain + provider.routeBaseName, login, canThis, bodyParser(), provider.post);
      app.get("" + this.options.domain + provider.routeBaseName + "/:id", login, canThis, provider.get);
      app.put("" + this.options.domain + provider.routeBaseName + "/:id", login, canThis, bodyParser(), provider.put);
      app["delete"]("" + this.options.domain + provider.routeBaseName + "/:id", login, canThis, provider["delete"]);
      _results.push(app.get("" + this.options.domain + provider.routeBaseName + "/:id/:collection", login, canThis, provider.subdoc));
    }
    return _results;
  };

  return API;

})();

module.exports = API;
