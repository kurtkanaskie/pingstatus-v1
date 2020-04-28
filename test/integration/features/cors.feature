@cors
Feature: CORS
	As API developer
	I want to ensure CORS requests are handled properly
	So I know Try It works from Spec Editor and Portals
    
	@cors-ping
    Scenario: Verify ping works with CORS
        Given I set X-APIKey header to invalid_id_not_verified
        Given I set Access-Control-Request-Method header to GET
        And I set Access-Control-Request-Headers header to x-apikey
		When I request OPTIONS for /ping
        Then response code should be 200
        And response header Access-Control-Allow-Headers should be x-apikey
        And response header Access-Control-Allow-Methods should be GET, PUT, POST, DELETE

	