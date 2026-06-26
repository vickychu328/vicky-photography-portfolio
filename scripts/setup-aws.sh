#!/bin/bash
# One-time setup: creates S3 bucket, ACM certificate, CloudFront distribution,
# and Route 53 DNS records for www.vickychu.com.
#
# Prerequisites:
#   - AWS CLI configured (aws configure) with admin permissions
#   - Route 53 hosted zone for vickychu.com already exists
#
# Usage:
#   AWS_REGION=us-west-2 ./scripts/setup-aws.sh
#
# After this runs, resource IDs are saved to .deploy.config (gitignored).

set -e

# ── Config ────────────────────────────────────────────────────────────────────
DOMAIN="vickychu.com"
WWW_DOMAIN="www.vickychu.com"
BUCKET_NAME="www.vickychu.com"
AWS_REGION=${AWS_REGION:-us-west-2}   # region for S3 bucket
CERT_REGION="us-east-1"               # ACM cert must be us-east-1 for CloudFront

echo "================================================"
echo "  Vicky Chu Photography — AWS Infrastructure Setup"
echo "================================================"
echo "Domain:  $WWW_DOMAIN"
echo "Bucket:  $BUCKET_NAME"
echo "Region:  $AWS_REGION"
echo ""

# ── 1. Get Route 53 Hosted Zone ID ───────────────────────────────────────────
echo "==> Looking up Route 53 hosted zone for $DOMAIN..."
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
  --dns-name "$DOMAIN." \
  --query "HostedZones[0].Id" \
  --output text | sed 's|/hostedzone/||')

if [ -z "$HOSTED_ZONE_ID" ] || [ "$HOSTED_ZONE_ID" = "None" ]; then
  echo "ERROR: No hosted zone found for $DOMAIN in Route 53."
  echo "Make sure the domain is registered and a hosted zone exists."
  exit 1
fi
echo "    Hosted Zone ID: $HOSTED_ZONE_ID"

# ── 2. Create S3 Bucket ───────────────────────────────────────────────────────
echo ""
echo "==> Creating S3 bucket: $BUCKET_NAME..."
if [ "$AWS_REGION" = "us-east-1" ]; then
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" 2>/dev/null || echo "    Bucket already exists, continuing..."
else
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION" 2>/dev/null || echo "    Bucket already exists, continuing..."
fi

# Block all public access (CloudFront OAC handles access)
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "    Bucket created and public access blocked."

# ── 3. Request ACM Certificate ────────────────────────────────────────────────
echo ""
echo "==> Requesting ACM certificate for $DOMAIN and $WWW_DOMAIN..."
CERT_ARN=$(aws acm request-certificate \
  --domain-name "$DOMAIN" \
  --subject-alternative-names "$WWW_DOMAIN" \
  --validation-method DNS \
  --region "$CERT_REGION" \
  --query "CertificateArn" \
  --output text)
echo "    Certificate ARN: $CERT_ARN"

# Wait for ACM to generate the DNS validation records
echo "    Waiting for DNS validation records to be generated..."
sleep 10

# Get the CNAME validation records
VALIDATION_RECORDS=$(aws acm describe-certificate \
  --certificate-arn "$CERT_ARN" \
  --region "$CERT_REGION" \
  --query "Certificate.DomainValidationOptions[*].ResourceRecord" \
  --output json)

CNAME_NAME=$(echo "$VALIDATION_RECORDS" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r[0]['Name'])")
CNAME_VALUE=$(echo "$VALIDATION_RECORDS" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r[0]['Value'])")

echo ""
echo "==> Adding DNS validation CNAME to Route 53..."
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch "{
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$CNAME_NAME\",
        \"Type\": \"CNAME\",
        \"TTL\": 300,
        \"ResourceRecords\": [{\"Value\": \"$CNAME_VALUE\"}]
      }
    }]
  }" > /dev/null
echo "    DNS validation record added."

echo ""
echo "==> Waiting for certificate validation (this can take 2-5 minutes)..."
aws acm wait certificate-validated \
  --certificate-arn "$CERT_ARN" \
  --region "$CERT_REGION"
echo "    Certificate validated!"

# ── 4. Create CloudFront Origin Access Control ────────────────────────────────
echo ""
echo "==> Creating CloudFront Origin Access Control..."
OAC_ID=$(aws cloudfront create-origin-access-control \
  --origin-access-control-config "{
    \"Name\": \"$BUCKET_NAME-oac\",
    \"Description\": \"OAC for $WWW_DOMAIN\",
    \"SigningProtocol\": \"sigv4\",
    \"SigningBehavior\": \"always\",
    \"OriginAccessControlOriginType\": \"s3\"
  }" \
  --query "OriginAccessControl.Id" \
  --output text)
echo "    OAC ID: $OAC_ID"

# ── 5. Create CloudFront Distribution ─────────────────────────────────────────
echo ""
echo "==> Creating CloudFront distribution (this takes ~5 minutes to deploy)..."
S3_DOMAIN="$BUCKET_NAME.s3.$AWS_REGION.amazonaws.com"

DIST_ID=$(aws cloudfront create-distribution \
  --distribution-config "{
    \"CallerReference\": \"vicky-portfolio-$(date +%s)\",
    \"Aliases\": {\"Quantity\": 2, \"Items\": [\"$DOMAIN\", \"$WWW_DOMAIN\"]},
    \"DefaultRootObject\": \"index.html\",
    \"Origins\": {
      \"Quantity\": 1,
      \"Items\": [{
        \"Id\": \"S3Origin\",
        \"DomainName\": \"$S3_DOMAIN\",
        \"S3OriginConfig\": {\"OriginAccessIdentity\": \"\"},
        \"OriginAccessControlId\": \"$OAC_ID\"
      }]
    },
    \"DefaultCacheBehavior\": {
      \"TargetOriginId\": \"S3Origin\",
      \"ViewerProtocolPolicy\": \"redirect-to-https\",
      \"CachePolicyId\": \"658327ea-f89d-4fab-a63d-7e88639e58f6\",
      \"Compress\": true,
      \"AllowedMethods\": {\"Quantity\": 2, \"Items\": [\"GET\", \"HEAD\"], \"CachedMethods\": {\"Quantity\": 2, \"Items\": [\"GET\", \"HEAD\"]}}
    },
    \"CustomErrorResponses\": {
      \"Quantity\": 2,
      \"Items\": [
        {\"ErrorCode\": 403, \"ResponsePagePath\": \"/index.html\", \"ResponseCode\": \"200\", \"ErrorCachingMinTTL\": 0},
        {\"ErrorCode\": 404, \"ResponsePagePath\": \"/index.html\", \"ResponseCode\": \"200\", \"ErrorCachingMinTTL\": 0}
      ]
    },
    \"PriceClass\": \"PriceClass_100\",
    \"Enabled\": true,
    \"ViewerCertificate\": {
      \"ACMCertificateArn\": \"$CERT_ARN\",
      \"SSLSupportMethod\": \"sni-only\",
      \"MinimumProtocolVersion\": \"TLSv1.2_2021\"
    },
    \"HttpVersion\": \"http2and3\",
    \"Comment\": \"$WWW_DOMAIN\"
  }" \
  --query "Distribution.Id" \
  --output text)

DIST_DOMAIN=$(aws cloudfront get-distribution \
  --id "$DIST_ID" \
  --query "Distribution.DomainName" \
  --output text)
echo "    Distribution ID: $DIST_ID"
echo "    Distribution domain: $DIST_DOMAIN"

# ── 6. Update S3 Bucket Policy to Allow CloudFront ───────────────────────────
echo ""
echo "==> Setting S3 bucket policy for CloudFront access..."
BUCKET_ARN="arn:aws:s3:::$BUCKET_NAME"
DIST_ARN="arn:aws:cloudfront::$(aws sts get-caller-identity --query Account --output text):distribution/$DIST_ID"

aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Sid\": \"AllowCloudFrontOAC\",
      \"Effect\": \"Allow\",
      \"Principal\": {\"Service\": \"cloudfront.amazonaws.com\"},
      \"Action\": \"s3:GetObject\",
      \"Resource\": \"$BUCKET_ARN/*\",
      \"Condition\": {\"StringEquals\": {\"AWS:SourceArn\": \"$DIST_ARN\"}}
    }]
  }"
echo "    Bucket policy updated."

# ── 7. Create Route 53 DNS Records ────────────────────────────────────────────
echo ""
echo "==> Creating Route 53 A records (alias) for $DOMAIN and $WWW_DOMAIN..."
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch "{
    \"Changes\": [
      {
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
          \"Name\": \"$WWW_DOMAIN\",
          \"Type\": \"A\",
          \"AliasTarget\": {
            \"HostedZoneId\": \"Z2FDTNDATAQYW2\",
            \"DNSName\": \"$DIST_DOMAIN\",
            \"EvaluateTargetHealth\": false
          }
        }
      },
      {
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
          \"Name\": \"$DOMAIN\",
          \"Type\": \"A\",
          \"AliasTarget\": {
            \"HostedZoneId\": \"Z2FDTNDATAQYW2\",
            \"DNSName\": \"$DIST_DOMAIN\",
            \"EvaluateTargetHealth\": false
          }
        }
      }
    ]
  }" > /dev/null
echo "    DNS records created."

# ── 8. Save Config for Future Deployments ─────────────────────────────────────
cat > .deploy.config <<EOF
BUCKET_NAME="$BUCKET_NAME"
DIST_ID="$DIST_ID"
AWS_REGION="$AWS_REGION"
EOF
echo ""
echo "    Resource IDs saved to .deploy.config"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo "  Setup complete!"
echo "================================================"
echo ""
echo "  CloudFront is deploying (takes ~5-10 minutes)."
echo "  Site will be live at:"
echo "    https://$WWW_DOMAIN"
echo "    https://$DOMAIN"
echo ""
echo "  To deploy the site files, run:"
echo "    ./scripts/deploy.sh"
echo ""
