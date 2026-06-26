#!/bin/bash
# Builds the Docker image locally for testing.
# Usage: ./scripts/build.sh [tag]
#   tag defaults to "local"
#
# To test locally after building:
#   docker run -p 8080:80 vicky-photography-portfolio:local
#   Then open http://localhost:8080

set -e

IMAGE_NAME="vicky-photography-portfolio"
TAG=${1:-local}

echo "Building Docker image: $IMAGE_NAME:$TAG"
docker build -t "$IMAGE_NAME:$TAG" .

echo ""
echo "Build complete. To test locally:"
echo "  docker run -p 8080:80 $IMAGE_NAME:$TAG"
echo "  Then open http://localhost:8080"
