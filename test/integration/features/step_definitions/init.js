/* jshint node:true */
'use strict';

var factory = require('./factory.js');
var config = require('../../test-config.json');

var apiproxy = config.apiconfig.apiproxy;
var basepath = config.apiconfig.basepath;
var clientId = config.apiconfig.clientId;
var clientSecret = config.apiconfig.clientSecret;

module.exports = function() {
    // cleanup before every scenario
    this.Before(function(scenario, callback) {
        this.apickli = factory.getNewApickliInstance();
        this.apickli.storeValueInScenarioScope("apiproxy", apiproxy);
        this.apickli.storeValueInScenarioScope("basepath", basepath);
        this.apickli.storeValueInScenarioScope("clientId", clientId);
        this.apickli.storeValueInScenarioScope("clientSecret", clientSecret);
        callback();
    });
};

