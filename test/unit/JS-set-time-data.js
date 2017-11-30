var expect = require('chai').expect;
var sinon = require('sinon');

var moduleLoader = require('./common/moduleLoader.js');
var mockFactory = require('./common/mockFactory.js');
var json = require('./common/jsonComparer.js');

var js = '../../../apiproxy/resources/jsc/JS-set-time-data.js';

describe('feature: ping and status time calculations', function() {

	it('should be total_client_time=150, total_target_time=200, total_request_time=350', function(done) {
		var mock = mockFactory.getMock();
		var timestamp = Date.now();
		var total_client_time;
		
		mock.contextGetVariableMethod.withArgs('client.received.start.timestamp').returns(timestamp);
		mock.contextGetVariableMethod.withArgs('target.sent.start.timestamp').returns(timestamp+50);
		mock.contextGetVariableMethod.withArgs('target.received.end.timestamp').returns(timestamp+250);
		mock.contextGetVariableMethod.withArgs('system.timestamp').returns(timestamp+350);

		moduleLoader.load(js, function(err) {
			expect(err).to.be.undefined;

			expect(mock.contextSetVariableMethod.calledWith('total_client_time','150')).to.be.true;
			expect(mock.contextSetVariableMethod.calledWith('total_target_time','200')).to.be.true;
			expect(mock.contextSetVariableMethod.calledWith('total_request_time','350')).to.be.true;
			done();
			
		});
	});

});
