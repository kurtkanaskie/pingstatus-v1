#! /bin/bash

# Get currently deployed revision in case build fields, so we can redeploy
# Script needs to run after set-edge-env-values.sh and Injecting env variables so EdgeEnv and EdgeDeploySuffix is correct.

# This script expects EdgeOrg, EdgeEnv and EdgeProxy env variables.
# export EdgeOrg="kurtkanaskietrainer-trial"
# export EdgeProxy="pingstatus-${EdgeDeploySuffix}v1"

# Deploy $PreviousRev
curl -s -X POST -u $EdgeInstallUsername:$EdgeInstallPassword --header "Content-Type: application/x-www-form-urlencoded" "https://api.enterprise.apigee.com/v1/o/$EdgeOrg/e/$EdgeEnv/apis/$EdgeProxy/revisions/$PreviousRev/deployments?override=true"
