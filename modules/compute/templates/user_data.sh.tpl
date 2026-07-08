# modules/compute/templates/user_data.sh.tpl
#!/bin/bash
set -euo pipefail

yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install useful tools
yum install -y htop jq

# Configure the Docker daemon to enable metrics (only accessible locally)
cat > /etc/docker/daemon.json <<EOF
{
  "metrics-addr" : "127.0.0.1:9323"
}
EOF

# Restart Docker to apply the configuration
systemctl restart docker

SSM_PREFIX="${ssm_prefix}"
AWS_REGION="${aws_region}"

IMDS_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IP=$(curl -s -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

%{ if role == "manager" ~}
# Manager node: initializes the swarm and publishes its IP + worker join
# token to SSM so workers can join without needing SSH or provisioners.
docker swarm init --advertise-addr "$LOCAL_IP"
WORKER_JOIN_TOKEN=$(docker swarm join-token -q worker)

aws ssm put-parameter --region "$AWS_REGION" --name "$SSM_PREFIX/manager-ip" --type String --overwrite --value "$LOCAL_IP"
aws ssm put-parameter --region "$AWS_REGION" --name "$SSM_PREFIX/worker-join-token" --type SecureString --overwrite --value "$WORKER_JOIN_TOKEN"
%{ else ~}
# Worker node: retries reading the manager IP and join token from SSM
# until the manager has published them, then joins the swarm.
MAX_ATTEMPTS=30
ATTEMPT=0
until MANAGER_IP=$(aws ssm get-parameter --region "$AWS_REGION" --name "$SSM_PREFIX/manager-ip" --query 'Parameter.Value' --output text 2>/dev/null) \
   && WORKER_JOIN_TOKEN=$(aws ssm get-parameter --region "$AWS_REGION" --name "$SSM_PREFIX/worker-join-token" --with-decryption --query 'Parameter.Value' --output text 2>/dev/null); do
  ATTEMPT=$((ATTEMPT + 1))
  if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "Timed out waiting for the swarm manager to publish join information" >&2
    exit 1
  fi
  sleep 10
done

docker swarm join --token "$WORKER_JOIN_TOKEN" "$MANAGER_IP:2377"
%{ endif ~}
