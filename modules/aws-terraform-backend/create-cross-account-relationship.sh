#!/bin/bash
######################################################################################
#                                                                                    #
#       AUTHOR: Félix González - felix.gonzalez@prefapp.es                           #
#                                                                                    #
#  DESCRIPTION: Script which launches the necesary aws cli commands in order         #
#               to create the cross account relationship for Terraform.              #
#                                                                                    #
#     REQUIRES: The following apps/commands must be installed an configured:         #
#                   - aws cli: AWS command line utils, with a profile with the       #
#                   - jq:      Command line JSON parser                              #
#                                                                                    #
#        USAGE: The following environment vars must be defined before launch:        #
#                                                                                    #
#               - AWS_REGION:   aws region for the deployment                        #
#               - AWS_PROFILE:  aws cli profile name                                 #
#               Then launch this script with ./create-cross-account-relationship.sh  #
#                   or bash create-cross-account-relationship.sh                     #
#                                                                                    #
#  EXAMPLE: AWS_REGION=eu-west-1 AWS_PROFILE=default /                               #
#           ./create-cross-account-relationship.sh                                   #
#                                                                                    #
######################################################################################

# Exit on error...
set -e

# ------ Check mandatory enviroment variables ----------------------------------
if ! command -v aws &> /dev/null; then
    echo "aws cli must be installed"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq must be installed"
    exit 1
fi


if [[ -z "${AWS_REGION}" ]]; then
    echo "AWS_REGION env var not defined. We will use the default value 'eu-west-1'"
    AWS_REGION="eu-west-1"
fi

if [[ -z "${AWS_PROFILE}" ]]; then
    echo "AWS_PROFILE must be defined with the aws profile to use (or use 'default')"
    exit 1
fi

# ---
AWS_ACCOUNT_ID = $(aws sts get-caller-identity --profile ${AWS_PROFILE} --query "Account" --output text)


# ------ Create resources using template ----------------------------------
# BackendAccountId

# Set stack name
echo "Creating aws cross account relationship for ACCOUNT_ID=${AWS_ACCOUNT_ID}"
# STACK_NAME="${PREFIX_LOWER}-tf-backend-stack"
STACK_NAME="cross-account-relationship"
# Let's create the stack with aws cli
aws cloudformation deploy \
    --stack-name ${STACK_NAME} \
    --template-file $(pwd)/create-cross-account-relationship.yaml \
    --parameter-overrides BackendAccountId=835677831763 \
    --no-fail-on-empty-changeset \
    --region=${AWS_REGION} \
    --disable-rollback \
    --profile ${AWS_PROFILE} \
    --output json

# ------ Wait for cloudformation to finish creation ---------------------------

STATUS=$(aws cloudformation describe-stacks \
                        --stack-name ${STACK_NAME} \
                        --profile ${AWS_PROFILE}  \
                        --output json \
                        --region ${AWS_REGION} | \
                        jq --arg stack "${STACK_NAME}" -c '.Stacks | .[] | select(.StackName == $stack) | .StackStatus' | \
                        sed 's/"//g')

while [ "$STATUS" == "CREATE_IN_PROGRESS" ]; do
    sleep 5
    STATUS=$(aws cloudformation describe-stacks \
                            --stack-name ${STACK_NAME} \
                            --profile ${AWS_PROFILE}  \
                            --output json \
                            --region ${AWS_REGION} | \
                            jq --arg stack "${STACK_NAME}" -c '.Stacks | .[] | select(.StackName == $stack) | .StackStatus' | \
                            sed 's/"//g')
done

echo "STATUS: ${STATUS}"

if [ "$STATUS" != "CREATE_COMPLETE" ] && [ "$STATUS" != "UPDATE_COMPLETE" ] && [ "$STATUS" != "UPDATE_ROLLBACK_COMPLETE" ] ; then
    echo "Stack creation failed, please clean the created resources..."
    exit 1
fi

# Get cloudformation outputs
STACK_OUTPUT=$(aws cloudformation describe-stacks \
                            --stack-name ${STACK_NAME} \
                            --profile ${AWS_PROFILE} \
                            --output json \
                            --region ${AWS_REGION} | jq --arg stack "${STACK_NAME}" -c '.Stacks | .[] | select(.StackName == $stack) |  .Outputs')

# Capture "important" values
ROLEARN=$(echo ${STACK_OUTPUT} | jq -c '.[] | select(.OutputKey == "TerraformRoleArn") | .OutputValue' | sed 's/\"//g')
ROLENAME=$(echo ${STACK_OUTPUT} | jq -c '.[] | select(.OutputKey == "TerraformRoleName") | .OutputValue' | sed 's/\"//g')


# ------ Show results data -----------------------------------------------------
echo ""
echo "DEPLOYED STACK ${STACK_NAME}:"
echo ""
echo "  - ROLE:           ${ROLENAME}"
echo "  - ROLE ARN:       ${ROLEARN}"


# ------ END --------------------------------------------------------------------
