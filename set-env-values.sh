#! /bin/bash

# If GIT_BRANCH is master or feature set EdgeEnv to "test"
# If GIT_BRANCH is feature set EdgeDeploySuffix to featurename
# /origin/master
# /origin/feature/jira1
# /origin/prod

echo BRANCH: $GIT_BRANCH

EdgeEnv="" 
EdgeDeploySuffix="" 

if [[ "$GIT_BRANCH" == origin/master ]]
then
	export EdgeEnv="test"
elif [[ "$GIT_BRANCH" = origin/feature/* ]]
then
	export EdgeEnv="test"
	export EdgeDeploySuffix=${GIT_BRANCH#/origin/feature/}
elif [[ "$GIT_BRANCH" == origin/prod ]]
then
	export EdgeEnv="prod"
else
	echo BRANCH PATH NOT FOUND
	exit 1
fi

echo EdgeEnv: $EdgeEnv
echo EdgeDeploySuffix: $EdgeDeploySuffix

