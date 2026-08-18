# RDS configuration
Create MySQL 8 in the required VPC and subnet group. Record the endpoint as `RDS_ENDPOINT`; set it as ECS `DB_HOST`. Keep the database private and allow 3306 only from the ECS task security group. Confirm database name, user, password, and security-group routing before troubleshooting the application.
