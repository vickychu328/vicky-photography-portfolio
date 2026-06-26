#!/bin/bash
# Builds the site and deploys to S3 + CloudFront.
# Run this whenever you make changes and want to go live.
#
# Prerequisites:
#   - Run scripts/setup-aws.sh once first
#   - AWS CLI configured (aws configure)
#
# Usage:
#   ./scripts/deploy.sh

set -e

# Load resource IDs saved by setup-aws.sh
if [ ! -f .deploy.config ]; then
  echo "ERROR: .deploy.config not found."
  echo "Run ./scripts/setup-aws.sh first to set up AWS infrastructure."
  exit 1
fi
source .deploy.config

echo "================================================"
echo "  Deploying to S3 + CloudFront"
echo "================================================"
echo "Bucket: $BUCKET_NAME"
echo "Distribution: $DIST_ID"
echo ""

# ── 1. Build ──────────────────────────────────────────────────────────────────
echo "==> Building site..."
npm run build
echo "    Build complete."

# ── 2. Sync to S3 ─────────────────────────────────────────────────────────────
echo ""
echo "==> Syncing files to S3..."

# index.html — no cache so users always get the latest version
aws s3 cp dist/index.html "s3://$BUCKET_NAME/index.html" \
  --cache-control "no-cache, no-store, must-revalidate" \
  --content-type "text/html" \
  --region "$AWS_REGION"

# Vite-hashed assets — immutable, cache for 1 year
aws s3 sync dist/assets "s3://$BUCKET_NAME/assets" \
  --cache-control "public, max-age=31536000, immutable" \
  --delete \
  --region "$AWS_REGION"

# Photos — cache for 30 days
aws s3 sync dist/photos "s3://$BUCKET_NAME/photos" \
  --cache-control "public, max-age=2592000" \
  --delete \
  --region "$AWS_REGION"

# Everything else (favicon, etc.)
aws s3 sync dist "s3://$BUCKET_NAME" \
  --exclude "index.html" \
  --exclude "assets/*" \
  --exclude "photos/*" \
  --cache-control "public, max-age=86400" \
  --delete \
  --region "$AWS_REGION"

echo "    Files synced."

# ── 3. Invalidate CloudFront Cache ────────────────────────────────────────────
echo ""
echo "==> Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$DIST_ID" \
  --paths "/*" \
  --query "Invalidation.Id" \
  --output text)
echo "    Invalidation started: $INVALIDATION_ID"
echo "    Changes will be live within ~30 seconds."

echo ""
echo "================================================"
echo "  Deployment complete!"
echo "  https://www.vickychu.com"
echo "================================================"
