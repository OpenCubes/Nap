var API;

API = require('./api.js');

module.exports = function(config) {
  return new API(config);
};
