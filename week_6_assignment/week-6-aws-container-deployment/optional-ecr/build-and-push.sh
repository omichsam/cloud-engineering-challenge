#!/bin/bash
set -euo pipefail
: "${AWS_REGION:?}"; : "${AWS_ACCOUNT_ID:?}"; : "${ECR_REPOSITORY:?}"
aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" >/dev/null 2>&1 || aws ecr create-repository --repository-name "$ECR_REPOSITORY" --region "$AWS_REGION"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
docker pull omarionya/task-tracker:latest
docker tag omarionya/task-tracker:latest "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest"
docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest"
