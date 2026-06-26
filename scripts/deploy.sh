#!/bin/bash
# Builds and pushes the Docker image to AWS ECR.
# Run this whenever you want to deploy changes.
#
# Prerequisites:
#   - AWS CLI configured (aws configure)
#   - Docker running
#   - ECR repo created (run scripts/setup-ecr.sh once first)
#
# Usage:
#   AWS_ACCOUNT_ID=123456789012 AWS_REGION=us-west-2 ./scripts/deploy.sh
#   Optionally pass a tag: ./scripts/deploy.sh v1.2

set -e

AWS_REGION=${AWS_REGION:-us-west-2}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:?Set AWS_ACCOUNT_ID before running this script}
REPO_NAME="vicky-photography-portfolio"
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
TAG=${1:-latest}

echo "==> Building image..."
docker build -t "$REPO_NAME:$TAG" .

echo ""
echo "==> Authenticating with ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo ""
echo "==> Tagging image..."
docker tag "$REPO_NAME:$TAG" "$ECR_URI:$TAG"
docker tag "$REPO_NAME:$TAG" "$ECR_URI:latest"

echo ""
echo "==> Pushing to ECR..."
docker push "$ECR_URI:$TAG"
docker push "$ECR_URI:latest"

echo ""
echo "Done! Image available at:"
echo "  $ECR_URI:$TAG"
echo "  $ECR_URI:latest"
echo ""
echo "If using App Runner, it will auto-deploy on ECR push if configured."
echo "If using ECS, trigger a new deployment:"
echo "  aws ecs update-service --cluster <cluster> --service <service> --force-new-deployment --region $AWS_REGION"
