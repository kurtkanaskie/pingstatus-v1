#! /bin/bash

# If GIT_BRANCH is master or feature set EdgeEnv to "test"
# If GIT_BRANCH is feature set EdgeDeploySuffix to featurename
# /origin/master
# /origin/feature/jira1
# /origin/prod

# echo BRANCH: $GIT_BRANCH

EdgeProfile="" 
EdgeDeploySuffix="" 

if [[ "$GIT_BRANCH" == origin/master ]]
then
	export EdgeProfile="training-test"
	export EdgeEnv="test"

elif [[ "$GIT_BRANCH" = origin/feature/* ]]
then
	export EdgeProfile="training-test"
	export EdgeEnv="test"
	# Get the feature name, tmp removes up to and including first /, do that again to get suffix
	tmp=${GIT_BRANCH#*/}
	export EdgeDeploySuffix=${tmp#*/}

elif [[ "$GIT_BRANCH" == origin/prod ]]
then
	export EdgeEnv="prod"
	export EdgeProfile="training-prod"
else
	echo BRANCH PATH NOT FOUND
	exit 1
fi
export EdgeOrg="kurtkanaskietrainer-trial"
export EdgeNorthboundDomain=$EdgeOrg-$EdgeEnv
# Expect to redirect output from this script to an "edge.properties" file.
echo EdgeOrg=$EdgeOrg
echo EdgeEnv=$EdgeEnv
echo EdgeNorthboundDomain=$EdgeNorthboundDomain
echo EdgeProfile=$EdgeProfile 
echo EdgeDeploySuffix=$EdgeDeploySuffix 
