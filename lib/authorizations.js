exports.canThis = function() {
  if (!this.config.authorizations) {
    return this.allow;
  }
  return this.getRole().then((function(_this) {
    return function(role) {
      console.log(role, _this.method, _this.config.authorizations);
      if (_this.config.authorizations) {
        switch (_this.method) {
          case "GET":
            if (["guest", "user", "admin"].indexOf(role) !== -1) {
              _this.allow();
            } else {
              _this.deny();
            }
            break;
          case "POST":
            if (["user", "admin"].indexOf(role) !== -1) {
              _this.allow();
            } else {
              _this.deny();
            }
            break;
          case "PUT":
            if (["admin"].indexOf(role) !== -1) {
              _this.allow();
            } else {
              _this.deny();
            }
            break;
          case "DELETE":
            if (["admin"].indexOf(role) !== -1) {
              _this.allow();
            } else {
              _this.deny();
            }
        }
      } else {
        return _this.allow();
      }
    };
  })(this)).fail(console.log);
};
