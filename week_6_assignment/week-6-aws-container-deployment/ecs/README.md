# ECS Fargate deployment
Create a Fargate cluster, replace placeholders in `task-definition.json`, create a task definition, then create a service with desired count 1, `awsvpc`, subnets, task security group, and port 80. Check task status, public IP, stopped-task reason, and CloudWatch logs. Prefer ECS secrets or Secrets Manager for credentials.
