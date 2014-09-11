var API;

API = require('./api');

module.exports = function(config) {
  return new API(config);
};
