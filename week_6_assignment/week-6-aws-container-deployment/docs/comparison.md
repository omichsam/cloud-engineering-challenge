# EC2 Docker vs ECS Fargate + RDS
| Concern | EC2 + containers | ECS Fargate + RDS |
|---|---|---|
| Management | Patch host and Docker | AWS manages task hosts; manage service config |
| Scaling | Manual instance/container scaling | Desired count and service deployments |
| Database | Self-managed MySQL volume | Managed backups, patching, and storage |
| Security | Host and container rules | VPC, task SG, RDS SG, IAM |
| Cost | Instance runs continuously | Pay for task runtime plus RDS |
| Availability | One host is a single point of failure | Easier multi-AZ/task designs |
| Complexity | Simpler for learning | More AWS networking/IAM setup |

EC2 is useful for understanding Docker directly; Fargate/RDS reduces operational responsibility for production-style workloads.
