var expect = require('chai').expect;
var sinon = require('sinon');

var contextGetVariableMethod,
	contextSetVariableMethod,
	httpClientSendMethod,
	requestConstr;

beforeEach(function() {
	global.context = {
		getVariable: function(s) {},
		setVariable: function(a, b) {}
	};

	global.httpClient = {
		send: function(s) {}
	};

	global.Request = function(s) {};

	contextGetVariableMethod = sinon.stub(global.context, 'getVariable');
	contextSetVariableMethod = sinon.spy(global.context, 'setVariable');
	httpClientSendMethod = sinon.stub(httpClient, 'send');
	requestConstr = sinon.spy(global, 'Request');

});

afterEach(function() {
	contextGetVariableMethod.restore();
	contextSetVariableMethod.restore();
	httpClientSendMethod.restore();
	requestConstr.restore();
});

exports.getMock = function() {
	return {
		contextGetVariableMethod: contextGetVariableMethod,
		contextSetVariableMethod: contextSetVariableMethod,
		httpClientSendMethod: httpClientSendMethod,
		requestConstr: requestConstr
	};
}
