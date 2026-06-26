#!/bin/bash
# One-time setup: creates the ECR repository in AWS.
# Run this once before your first deployment.
#
# Usage: AWS_ACCOUNT_ID=123456789012 AWS_REGION=us-west-2 ./scripts/setup-ecr.sh

set -e

AWS_REGION=${AWS_REGION:-us-west-2}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:?Set AWS_ACCOUNT_ID before running this script}
REPO_NAME="vicky-photography-portfolio"

echo "Creating ECR repository: $REPO_NAME in $AWS_REGION..."

aws ecr create-repository \
  --repository-name "$REPO_NAME" \
  --region "$AWS_REGION" \
  --image-scanning-configuration scanOnPush=true \
  --query "repository.repositoryUri" \
  --output text

echo ""
echo "ECR repository created."
echo "Repository URI: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
echo ""
echo "Next: run ./scripts/deploy.sh to build and push your first image."
