# Networking and security
EC2 uses a private Docker network and publishes only HTTP. ECS uses VPC subnets, a task security group, and an RDS security group allowing TCP 3306 from the task SG. Restrict SSH to My IP, keep RDS private, use Secrets Manager for credentials, and never commit keys or passwords.
