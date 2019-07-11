#! /bin/bash

# If GIT_BRANCH is master or feature set EdgeEnv to "test"
# If GIT_BRANCH is feature set EdgeDeploySuffix to featurename
# /origin/master
# /origin/feature/jira1
# /origin/prod

# echo BRANCH: $GIT_BRANCH

# This script is hard coded with org and proxy name
export EdgeOrg="kurtkanaskietrainer-trial"

EdgeProfile="" 
EdgeDeploySuffix="" 

if [[ "$GIT_BRANCH" == origin/master ]]
then
	export EdgeProfile="test"
	export EdgeEnv="test"

elif [[ "$GIT_BRANCH" = origin/feature/* ]]
then
	export EdgeProfile="test"
	export EdgeEnv="test"
	# Get the feature name, tmp removes up to and including first /, do that again to get suffix
	tmp=${GIT_BRANCH#*/}
	export EdgeDeploySuffix=${tmp#*/}

elif [[ "$GIT_BRANCH" == origin/prod ]]
then
	export EdgeEnv="prod"
	export EdgeProfile="prod"
else
	echo BRANCH PATH NOT FOUND
	exit 1
fi

export EdgeNorthboundDomain=$EdgeOrg-$EdgeEnv.apigee.net

# ConfigChanges=`git diff --name-only HEAD HEAD~1 | grep "edge.json"`
ConfigChanges=`git diff --name-only HEAD HEAD~1 | grep "resources"`
if [[ $? -eq 0 ]]
then
	export EdgeConfigOptions="update"
else
	export EdgeConfigOptions="none"
fi

# This script is hard coded with proxy name and EdgeDeploySuffix as per pom.xml
export EdgeProxy="pingstatus-${EdgeDeploySuffix}v1"

# Get currently deployed revision in case build fields, so we can redeploy
EdgePreRev=`curl -s -u $EdgeInstallUsername:$EdgeInstallPassword https://api.enterprise.apigee.com/v1/o/$EdgeOrg/e/$EdgeEnv/apis/$EdgeProxy/deployments | grep '^    "name"' | cut -d '"' -f 4`
export EdgePreRev=$EdgePreRev

# Expect to redirect output from this script to an "edge.properties" file.
echo EdgeOrg=$EdgeOrg
echo EdgeEnv=$EdgeEnv
echo EdgeNorthboundDomain=$EdgeNorthboundDomain
echo EdgeProfile=$EdgeProfile 
echo EdgeDeploySuffix=$EdgeDeploySuffix 
echo EdgeConfigOptions=$EdgeConfigOptions

echo EdgeProxy=$EdgeProxy
echo EdgePreRev=$EdgePreRev


