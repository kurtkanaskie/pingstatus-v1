@health
Feature: API proxy health
	As API administrator
	I want to monitor Apigee proxy and backend service health
	So I can alert when it is down
    
	@get-ping
    Scenario: Verify the API proxy is responding
        Given I set X-APIKey header to `clientId`
		When I GET /ping
        Then response code should be 200
        And response header Content-Type should be application/json
        # And response body path $.environment should be dev
        And response body path $.apiproxy should be `apiproxy`
        And response body path $.client should be ^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$
        And response body path $.latency should be ^\d{1,2}
        And response body path $.message should be PONG

	@get-status
    Scenario: Verify the backend service is responding
        Given I set X-APIKey header to `clientId`
		When I GET /status
        Then response code should be 200
        And response header Content-Type should be application/json
        # And response body path $.environment should be dev
        And response body path $.apiproxy should be `apiproxy`
        And response body path $.basepath should be `basepath`
        And response body path $.client should be ^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$
        And response body path $.latency should be ^\d{1,2}
        And response body path $.message should be STATUS
        
