# Architecture
The EC2 design places PHP and MySQL on one host connected by Docker DNS. The managed design places PHP in a Fargate task and MySQL in RDS over private VPC networking. In both cases the application connects using a hostname, not localhost.
