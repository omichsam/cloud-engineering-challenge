# RDS configuration
Choose MySQL 8, a lab-sized instance, a DB name/user, VPC and subnet group. Prefer private accessibility. Copy the generated endpoint into `DB_HOST`; never use localhost. Permit 3306 only from the ECS task security group.
