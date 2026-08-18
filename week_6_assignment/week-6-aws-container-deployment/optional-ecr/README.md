# Optional ECR bonus
Set `AWS_REGION`, `AWS_ACCOUNT_ID`, and `ECR_REPOSITORY`, authenticate with AWS CLI, and run `build-and-push.sh`. ECR is AWS's private image registry; Docker Hub is a separate public/third-party registry. Update the ECS task image and deploy a new task-definition revision.
