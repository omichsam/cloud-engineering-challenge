# Troubleshooting
| Symptom | Check | Likely solution |
|---|---|---|
| Docker daemon/permission error | `docker ps` | Start Docker; use `sudo` or add user to docker group and reconnect |
| MySQL restarting/not ready | `docker logs task-tracker-mysql` | Check credentials, volume, and allow startup time |
| App cannot connect | `docker network inspect task-tracker-network` | Use `task-tracker-mysql`, not localhost; confirm matching variables |
| SSH timeout | EC2 SG and route | Allow TCP 22 from My IP; verify public IP/key |
| HTTP unavailable | `docker ps`, EC2 SG | Confirm port 80 mapping and inbound HTTP rule |
| ECS task stops | Stopped task reason and CloudWatch logs | Fix image, port, IAM execution role, or env variables |
| Image pull failure | ECS events / Docker pull | Check image name, registry access, and ECR permissions |
| RDS timeout | RDS SG, task SG, subnets | Allow 3306 from task SG and use the RDS endpoint |
