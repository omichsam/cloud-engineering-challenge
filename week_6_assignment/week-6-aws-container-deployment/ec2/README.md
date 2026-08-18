# EC2 deployment
Run `docker-network.sh`, set secrets in your shell, run `run-mysql.sh`, then `run-app.sh`. `verify.sh` checks containers, network, and logs. `stop-containers.sh` preserves the database volume; `cleanup.sh` deletes containers, network, and volume. Open port 80 in the EC2 security group and restrict SSH 22 to your IP.
