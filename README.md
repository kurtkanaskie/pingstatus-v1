# Ping and Status

## Overview
Each proxy source code module is self contained with the actual Apigee Edge proxy, config files for Edge Management API calls (e.g. KVMs, target servers), swagger spec and tests.
The key components enabling continuous integration are:
* Jenkins - build engine
* Maven - builder
* Apickli - cucumber extension for RESTful API testing
* Cucumber - Behavior Driven Development
* JMeter - Performance testing

Basically, everything that Jenkins does using Maven and other tools can be done locally, either directly with the tool (e.g. jslint, cucumberjs) or via Maven commands. The sections below show how to do each.

Jenkins projects are set up to run using Maven and Maven runs via configurations in a pom file (pom.xml). Maven follows a phased approach to execute commands and generally the result of that execution is to create a "target" directory to hold the output ultimately results in loading the proxy into Apigee Edge. Some commonly used commands are:
* clean - remove the target directory
* copy-resources - copy the source files to the target applying any filtering or replacement
* package - copy the source files and bundle into zip file for deployment to Apigee
* install - copy, package and install into Apigee
* integration - run integration tests

## Git Commands

### Intitial
* git checkout -b prod
* git push origin prod
* git checkout master

### Feature
* git checkout -b feature/jira1 --- (MAKE changes for feature/jira1)

#### Test locally
Set your ~/.m2/settings.xml
##### Initial build and deploy to currencty-"yourusername"v1
* mvn -X install -Ptest -Dcommit=local -Dbranch=feature/jira1 
##### Run unit tests and integration tests
* mvn process-resources exec:exec@unit -Ptest
* mvn process-resources exec:exec@integration -Ptest
##### To run integration tests in other environments
* mvn process-resources exec:exec@integration -Ptest -Ddeployment.suffix=
* mvn process-resources exec:exec@integration -Pprod -Ddeployment.suffix=

Once you're happy with the "new" tests locally and verify the feature "doesn't work" in test and prod, then move on to building via Jenkins.

#### Test via Jenkins
* git commit -am  "Added changes for feature1"
* git push origin feature/jira1

If the build succeeds you're ready to move into the master branch.

#### Merge to Master
##### Pull Request
* Go to repo and create pull request from feature/jira1 to master
* Comment on pull request
* Do the merge pull request "Create a merge commit" or use command line

##### Via command line
* git checkout master
* git merge --no-ff feature/jira1
* git push

Clean up feature branch
* git branch -d feature/jira1
* git push origin --delete feature/jira1

Or using this:
* git push origin :feature/jira1

#### Update local Master
* git checkout master
* git pull

### Merge to Environments qa, stage, sandbox, prod


## Maven
### Jenkins Commands
The Jenkins build server runs Maven with this command for each of the feature branches. 

```
mvn -Pmy-test clean install -Dapi.testtag=@intg,@health
```

Note the lack of `-deployment.suffix=`. That is so the build and deploy to Apigee creates a separate proxy with a separate basepath to allow independent feature development. Your proxy will show up with a name (e.g. pingstatus-${user.name}v1) and basepath (e.g. /pingstatus/${user.name}v1).

For other environments (e.g. test, prod) the `-deployment.suffix=` is set blank, so the build puts the proxy into the final form with the final basepath (e.g. pingstatus-v1, /pingstatus/v1).
```
mvn -P test clean install  -Ddeployment.suffix= -Dapi.testtag=@intg,@health
```


NOTE: If you get a strange error from Maven about replacement `named capturing group is missing trailing '}'` there is something wrong with your options or replacements settings.

In addition to "replacing" that string other Maven phases (e.g. process-resources) do some inline replacement to support the feature proxy.
The most important change is to the `test/apickli/config/config.json` file which changes the basepath for the proxy so the tests go to the correct feature proxy in Apigee.


## Local Install and Set Up
In each source directory there is a `package.json` file that holds the required node packages.

* Install node
* Install maven
* Install Apickli and cucumberjs
    * cd source directory
    * `npm install` (creates node_modules)
    * `npm install -g cucumberjs` (installs command line tools per OS (e.g. cucumberjs)


## Running Tests Locally
Often it is necessary to interate over tests for a feature development. Since Apickli/Cucumber tests are mostly text based, its easy to do this locally. 
Here are the steps:
1 Install your feature proxy to Apigee if you are creating a new feature, otherwise just get a copy of the exising proxy you are building tests for.
2 Run Maven to copy resources and "replace" things. 
    * `mvn -P test clean process-resources`
3 Run tests by tag or by feature file
    * cucumberjs target/test/apickli/features --tags @intg
    * cucumberjs target/test/apickli/features/errorHandling.feature

Alternatively, you can run the tests via Maven
* `mvn -P test process-resources exec:exec@integration -api.testtag=@get-ping`

NOTE: the initial output from cucumber shows the proxy and basepath being used
```
    [yourname]$ cucumberjs test/apickli/features --tags @invalid-clientid-for-resource
==> pingstatus api: [yourorgname-test.apigee.net, /pingstatus/yournamev1]
    @intg
    Feature: Error handling

      As an API consumer
      I want consistent and meaningful error responses
      So that I can handle the errors correctly

      @invalid-clientid-for-resource
      Scenario: GET with invalid clientId for resource
        Given I set clientId header to `invalidClientId`
        When I GET /ping
        Then response code should be 400
        And response header Content-Type should be application/json
        And response body path $.message should be missing or invalid clientId
```

#### Tests
To see what "tags" are in the tests for cucumberjs run `grep @ *.features` or `find . -name *.feature -exec grep @ {} \;`
```
@intg
    @invalidclientid
    @invalid-clientid-for-resource
    @foo
    @foobar
@health
    @get-ping
    @get-statuses
```
## Other Miscellaneous Commands
#### Install and Run Tests by tag as default username
* mvn -P test install -Dapi.testtag=@health,@intg

#### Install and Run Tests by tag as no username (master)
* mvn -P test clean install -Dapi.testtag=@health,@intg -Ddeployment.suffix=

#### Process-resources and Run Tests by tag
* mvn -P test process-resources exec:exec@integration -Dapi.testtag=@health

#### Install and sync configuration items
mvn install -Pprod -Ddeployment.suffix= -Dapigee.config.options=sync -Dcommit=local -Dbranch=master

### JMeter
To prevent jmeter from running use -DskipPerformanceTests=true
jmeter -n -j target/test/performance/jmeter.log -l target/test/performance/output.txt -t target/test/performance/test.jmx -DtestData=testdata.csv -DthreadNum=10 -DrampUpPeriodSecs=1 -DloopCount=4 -Drecycle=true

### JSLint
* jslint apiproxy/resources/jsc
* mvn -P test jshint:lint
* mvn -P test jshint:lint@jslint

### Aplicki / Cucumber Standalone Tests
* mvn -Ptest process-resources exec:exec@integration -Ddeployment.suffix= -Dapi.testtag=@get-ping
* node ./node_modules/cucumber/bin/cucumber.js target/test/integration/features --tags @get-status

NOTE: For some reason the latest cucumber (2.3.4) doesnt work with apickli-gherkin.js, it doesnt find it, so use 1.3.3

#### Diffing apiproxy directories
* diff -q --suppress-common-lines -r --side-by-side apiproxy-prev apiproxy -W 240
* diff --suppress-common-lines -r --side-by-side apiproxy-prev apiproxy -W 240

### Maven $HOME/.m2/settings.xml 
```
<profile>
            <id>test</id>
            <properties>
                <env.APIGEE_ORG>yourorgname</env.APIGEE_ORG>
                <env.APIGEE_USERNAME>yourusername</env.APIGEE_USERNAME>
                <env.APIGEE_PASSWORD>yourpassword</env.APIGEE_PASSWORD>
                <env.APIGEE_NORTHBOUND_DOMAIN>yourorgname-test.apigee.net</env.APIGEE_NORTHBOUND_DOMAIN>
            </properties>
        </profile>
        <profile>
            <id>prod</id>
            <properties>
                <env.APIGEE_ORG>yourorgname</env.APIGEE_ORG>
                <env.APIGEE_USERNAME>yourusername</env.APIGEE_USERNAME>
                <env.APIGEE_PASSWORD>yourpassword</env.APIGEE_PASSWORD>
                <env.APIGEE_NORTHBOUND_DOMAIN>yourorgname-prod.apigee.net</env.APIGEE_NORTHBOUND_DOMAIN>
            </properties>
        </profile>
```

### Frequently used commands
mvn jshint:lint
mvn -Ptest exec:exec@unit
mvn -Ptest install -Ddeployment.suffix=
mvn -Ptest install -Ddeployment.suffix= -Dapi.testtag=@get-ping -DskipTests=true
mvn -Ptest process-resources exec:exec@integration -Ddeployment.suffix= -Dapi.testtag=@get-ping
mvn -Ptest install -Ddeployment.suffix= -Dapigee.config.options=sync -Dapi.testtag=@get-ping
mvn -Ptest clean process-resources jmeter:jmeter jmeter-analysis:analyze -Ddeployment.suffix=
mvn -Ptest clean process-resources -Ddeployment.suffix= exec:exec@integration -Dapi.testtag=@get-status
mvn -Ptest apigee-config:developers apigee-config:apiproducts apigee-config:developerapps -Dapigee.config.options=update
mvn -Ptest apigee-config:exportAppKeys -Dapigee.config.exportDir=./appkeys
mvn -Ptest install -Ddeployment.suffix= -Dapi.testtag=@get-ping -DskipPerformanceTests=true
mvn -Ptest clean process-resources -Ddeployment.suffix= exec:exec@integration -Dapi.testtag=@get-ping

mvn -Ptest apigee-config:targetservers -Dapigee.config.options=update
mvn -Ptest apigee-config:developerapps -Dapigee.config.options=update
mvn -Ptest apigee-config:apiproducts -Dapigee.config.options=update
mvn -Ptest apigee-config:kvms -Dapigee.config.options=update

Install proxy no integration or jmeter tests
mvn -Ptest install -Ddeployment.suffix= -Dapi.testtag=@NONE -DskipPerformanceTests=true

Install proxy and update all configs, no integration or jmeter tests
mvn -Ptest install -Ddeployment.suffix= -Dapigee.config.options=update -Dapi.testtag=@NONE -DskipPerformanceTests=true

Export App keys
mvn -Ptest apigee-config:exportAppKeys -Dapigee.config.exportDir=./appkeys

Change
