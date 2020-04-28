#! /bin/bash

# This script is hard coded for EdgeOrg and EdgeProxy
# This script is hard coded with proxy name and EdgeDeploySuffix as per pom.xml (see below)
# Expects envs of "test" and "prod"

# If GIT_BRANCH is master or feature, set EdgeEnv to "test"
# Else If GIT_BRANCH is feature, set EdgeDeploySuffix to featurename
# Else If GIT_BRANCH is prod, set EdgeEnv to "prod"
# /origin/master
# /origin/feature/jira1
# /origin/prod

# echo BRANCH: $GIT_BRANCH
# Test via:
# GIT_BRANCH=origin/master set-edge-env-values.sh 
# GIT_BRANCH=origin/prod set-edge-env-values.sh 
# GIT_BRANCH=origin/feature/1 set-edge-env-values.sh 

export EdgeOrg="kurtkanaskiecicd-eval"

EdgeProfile="" 
EdgeDeploySuffix="" 

if [[ "$GIT_BRANCH" == origin/master ]]
then
	export EdgeProfile="test"
	export EdgeEnv="test"

elif [[ "$GIT_BRANCH" == origin/feature/* ]]
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

export EdgeProxy="pingstatus-${EdgeDeploySuffix}v1"

# Expect to redirect output from this script to an "edge.properties" file.
echo EdgeOrg=$EdgeOrg
echo EdgeEnv=$EdgeEnv
echo EdgeNorthboundDomain=$EdgeNorthboundDomain
echo EdgeProfile=$EdgeProfile 
echo EdgeDeploySuffix=$EdgeDeploySuffix 
echo EdgeConfigOptions=$EdgeConfigOptions
echo EdgeProxy=$EdgeProxy
