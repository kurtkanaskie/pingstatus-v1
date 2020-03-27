# Ping and Status API Update

This proxy demonstrates a simple design to demonstrate a full CI/CD lifecycle.
It uses the following health check or monitoring endpoints
* GET /ping - response indicates that the proxy is operational
* GET /status - response indicates the the backend is operational

These endpoints can then be used by API Monitorying with Edge to send notifications when something is wrong.

## Disclaimer

This example is not an official Google product, nor is it part of an official Google product.

## License

This material is copyright 2019, Google LLC. and is licensed under the Apache 2.0 license.
See the [LICENSE](LICENSE) file.

This code is open source.

## Overview
Each proxy is managed as a single source code module that is self contained with the actual Apigee Edge proxy, config files for Edge Management API calls (e.g. KVMs, target servers), Open API Specification (OAS) and tests (status, unit, integration).

The key components enabling continuous integration are:
* Jenkins or GCP Cloud Build - build engine
* Maven - builder
* npm, node - to run unit and integration tests
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

#### Initial Deploy
Set your $HOME/.m2/settings.xml  
Example:
```
<?xml version="1.0"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <profiles>
        <profile>
            <id>test</id>
            <!-- These are also the values for environment variables used by set-edge-env-values.sh for Jenkins -->
            <properties>
                <EdgeOrg>yourorgname</EdgeOrg>
                <EdgeEnv>yourenv</EdgeEnv>
                <EdgeUsername>yourusername@exco.com</EdgeUsername>
                <EdgePassword>yourpassword</EdgePassword>
                <EdgeNorthboundDomain>yourourgname-yourenv.apigee.net</EdgeNorthboundDomain>
                <EdgeAuthtype>oauth</EdgeAuthtype>
            </properties>
        </profile>
        ...
    </profiles>
</settings>
```
##### Initial build and deploy to pingstatus-v1
```
mvn -P test install -Ddeployment.suffix= -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health
```
### Feature
* git checkout -b feature/jira1 --- (MAKE changes for feature/jira1)

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
* git checkout prod
* git pull
* git merge --no-ff master
* git push
* git checkout master

## Maven
### Jenkins Commands
The Jenkins build server runs Maven with this commands.

Set Environment variables via script
```
./set-edge-env-values.sh > edge.properties
```
This allows a single build project to be used for each of the branches including feature branches.

```
install -P${EdgeProfile} -Ddeployment.suffix=${EdgeDeploySuffix} -Dapigee.org=${EdgeOrg} -Dapigee.env=${EdgeEnv} -Dapi.northbound.domain=${EdgeNorthboundDomain} -Dapigee.username=${EdgeInstallUsername} -Dapigee.password=${EdgeInstallPassword} -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dcommit=${GIT_COMMIT} -Dbranch=${GIT_BRANCH}
```

Note the use of `-deployment.suffix=`. That is so the build and deploy to Apigee creates a separate proxy with a separate basepath to allow independent feature development. Your proxy will show up with a name (e.g. pingstatus-${user.name}v1) and basepath (e.g. /pingstatus/${user.name}v1).

For other environments (e.g. test, prod) the `-deployment.suffix=` is set blank, so the build puts the proxy into the final form with the final basepath (e.g. pingstatus-v1, /pingstatus/v1).
```
mvn -P test clean install  -Ddeployment.suffix= -Dapi.testtag=@intg,@health
```


NOTE: If you get a strange error from Maven about replacement `named capturing group is missing trailing '}'` there is something wrong with your options or replacements settings. Use '-X' and look for unfulfilled variables (e.g. ${apigee.username}).

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

## Specific Usage
### Maven $HOME/.m2/settings.xml
```
<profile>
    <id>test</id>
    <!-- These are also the values for environment variables used by set-edge-env-values.sh for Jenkins -->
    <properties>
        <EdgeOrg>yourorgname</EdgeOrg>
        <EdgeEnv>test</EdgeEnv>
        <EdgeUsername>yourusername</EdgeUsername>
        <EdgePassword>yourpassword</EdgePassword>
        <EdgeNorthboundDomain>yourorgname-yourenv.apigee.net</EdgeNorthboundDomain>
        <EdgeAuthtype>oauth</EdgeAuthtype>
    </properties>
</profile>
<profile>
    <id>prod</id>
    <properties>
        <EdgeOrg>yourorgname</EdgeOrg>
        <EdgeEnv>prod</EdgeEnv>
        <EdgeUsername>yourusername</EdgeUsername>
        <EdgePassword>yourpassword</EdgePassword>
        <EdgeNorthboundDomain>yourorgname-yourenv.apigee.net</EdgeNorthboundDomain>
        <EdgeAuthtype>oauth</EdgeAuthtype>
    </properties>
</profile>

```

## All at once - full build and deploy
Replacer copies and replaces the resources dir into the target. Note use of -Dapigee.config.dir option.

### Maven all at once
* mvn -P test install -Ddeployment.suffix= -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapigee.smartdocs.config.options=update

### Cloud Build all at once
* cloud-build-local --dryrun=true --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .
* cloud-build-local --dryrun=false --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .

## Other commands for iterations

### Full install and test, but skip cleaning target
* mvn -P test install -Ddeployment.suffix= -Dskip.clean=true -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health

### Skip clean and export - just install, deploy and test
* mvn -P test install -Ddeployment.suffix= -Dskip.clean=true -Dskip.export=true -Dapigee.config.options=none -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health

### Just update Developers, Products and Apps
* mvn -P test process-resources apigee-config:developers apigee-config:apiproducts apigee-config:apps apigee-config:exportAppKeys -Dapigee.config.options=update -Ddeployment.suffix= -Dskip.clean=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration

### Just update KVM
* mvn -P test process-resources apigee-config:kvms -Dapigee.config.options=update -Ddeployment.suffix= -Dskip.clean=true -Dapigee.config.dir=target/resources/edge

### Just update Target Servers
* mvn -P test process-resources apigee-config:targetservers -Dapigee.config.options=update -Ddeployment.suffix= -Dskip.clean=true -Dapigee.config.dir=target/resources/edge

### Export App keys
* mvn -P test apigee-config:exportAppKeys -Ddeployment.suffix= -Dskip.clean=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration

### Export Apps and run the tests (after skip.clean)
* mvn -P test process-resources apigee-config:exportAppKeys frontend:npm@integration -Ddeployment.suffix= -Dskip.clean=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@get-ping

### Just run the tests (after skip.clean) - for test iterations
* mvn -P test process-resources -Ddeployment.suffix= -Dskip.clean=true frontend:npm@integration -Dapi.testtag=@health

### Skip Creating Apps and Overwrite latest revision
* mvn -P test install -Ddeployment.suffix= -Dapigee.config.options=update -Dapigee.options=update -Dskip.apps=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health

### Just update the API Specs
* mvn -P test apigee-smartdocs:apidoc -Dapigee.smartdocs.config.options=update

### Just update the Integrated Portal API Specs
Via process-resources after replacements or when in target
* mvn -X -P test process-resources apigee-config:specs -Dapigee.config.options=update -Ddeployment.suffix= -Dskip.clean=true -Dapigee.config.dir=target/resources/edge
* mvn -P test -Dapigee.config.options=update apigee-config:specs -Dapigee.config.dir=target/resources/specs -Dapigee.config.dir=target/resources/edge

Via the source without replacements
* mvn -P test -Dapigee.config.options=update apigee-config:specs -Dapigee.config.dir=target/resources/specs -Dapigee.config.dir=resources/edge

### Other discrete commands
* mvn -Ptest validate (runs all validate phases: lint, apigeelint, unit)
* mvn jshint:lint
* mvn -Ptest frontend:npm@apigeelint
* mvn -Ptest frontend:npm@unit
* mvn -Ptest frontend:npm@integration
