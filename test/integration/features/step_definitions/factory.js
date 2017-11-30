var apickli = require('apickli');
var config = require('../../test-config.json');

var defaultBasePath = config.apiconfig.basepath;
var defaultDomain = config.apiconfig.domain;

console.log('apiconfig: [' + config.apiconfig.domain + ', ' + config.apiconfig.basepath + ']');

var getNewApickliInstance = function(basepath, domain) {
	basepath = basepath || defaultBasePath;
	domain = domain || defaultDomain;

	return new apickli.Apickli('https', domain + basepath);
};

exports.getNewApickliInstance = getNewApickliInstance;
