# modules/compute/templates/user_data.sh
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Instalar herramientas útiles
yum install -y htop jq

# Configurar Docker daemon para habilitar métricas
cat > /etc/docker/daemon.json <<EOF
{
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
EOF

# Reiniciar Docker para aplicar la configuración
systemctl restart docker