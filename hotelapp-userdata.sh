#!/bin/bash
sudo set -euo pipefail

# --------------------------
# EC2 User-Data for Bluebird Hotel App
# --------------------------

# Update system packages
sudo apt update && apt upgrade -y

# Install Apache, PHP, MySQL, and required PHP extensions
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
  apache2 php libapache2-mod-php php-mysql mysql-client mysql-server \
  php-curl php-json php-gd php-mbstring php-xml php-xmlrpc \
  git unzip

# Install Docker
sudo apt install docker.io docker-compose -y 
sudo systemctl start docker
sudo systemctl enable docker

# Add the default user to the docker group (optional, adjust user if needed)
sudo usermod -aG docker ubuntu


# Install AWS CLI (for future ECR push/pull)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
sudo rm -rf awscliv2.zip aws

# AWS Configure via IAM Role already attached to ec2
sudo aws s3 ls

# Get a metadata token (IMDSv2)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Use the token to get the instance ID (or any other metadata)
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

# Do something with the metadata, e.g., log it
#echo "Instance ID: $INSTANCE_ID" > /home/ubuntu/instance-id.txt
#chown ubuntu:ubuntu /home/ubuntu/instance-id.txt


# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2

# --------------------------
# Deploy Application
# --------------------------

# Remove default Apache web root content
sudo rm -rf /var/www/html/*

# Clone app directly into Apache web root
sudo git clone https://github.com/brainscalesolutions/hotel_management.git /var/www/html


# --------------------------
# MySQL Configuration
# --------------------------
MYSQL_ROOT_PASSWORD="rootpass"
DB_NAME="bluebirdhotel"
DB_USER="bluebird_user"
DB_PASS="Test1234"

# Set MySQL root password and configure user/database
sudo echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';" | mysql

# Create the database and user
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# --------------------------
# Generate config.php
# --------------------------
sudo cat > /var/www/html/config.php <<PHP
<?php
\$server   = "localhost";
\$username = "${DB_USER}";
\$password = "${DB_PASS}";
\$database = "${DB_NAME}";

\$conn = mysqli_connect(\$server, \$username, \$password, \$database);

if (!\$conn) {
    die("<script>alert('connection Failed.')</script>");
}
?>
PHP

sudo tee /var/www/html/Dockerfile > /dev/null <<'EOF'
# Use the centos:centos7 base image
FROM ubuntu:24.04

# Set the working directory inside the container
WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y
RUN apt install apache2 php libapache2-mod-php php-mysql mysql-client -y

# Copy all files from the current directory into the container's /app directory
COPY . .

RUN bash ./setup.sh

EXPOSE 80

# Command to run when the container starts
CMD ["/bin/bash", "-c", "service apache2 start && tail -f /dev/null"]
EOF

sudo tee /var/www/html/setup.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
# This script installs dependencies and runs the project
# Run this with root user on Linux Machines(Rocky Linux)
# Start apache
service apache2 start
service apache2 enable

# Replace 'hostname', 'username', and 'password' with the actual RDS credentials.
mysql -h localhost -u bluebird_user -p'Test1234' < ./bluebirdhotel.sql


# Copy project to /var/www/html
rm -r /var/www/html/index.html
cp -r ./ /var/www/html/

# restart apache
service apache2 start

echo "View project at: http://localhost:80/"
EOF

# Set proper ownership/permissions
#sudo chown -R www-data:www-data /var/www/html/
#sudo chmod -R 755 /var/www/html/

# Restart Apache to apply changes
sudo systemctl restart apache2

# Set your variables
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=eu-north-1
IMAGE_TAG=tf-latest
REPO_NAME=hotelapp-tf

cd /var/www/html || exit
# Build Docker image with the tag
docker build -t hotelapp:$IMAGE_TAG .

# Create the ECR repository if it doesn't exist
aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Creating ECR repository: $REPO_NAME"
    aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION
else
    echo "ECR repository $REPO_NAME already exists."
fi

# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

ECR_IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"
# Tag and push the Docker image to ECR
docker tag hotelapp:$IMAGE_TAG "$ECR_IMAGE_URI"
docker push "$ECR_IMAGE_URI"

docker pull "$ECR_IMAGE_URI"

# Run Docker container
sudo docker run -d -p 80:80 "$ECR_IMAGE_URI"

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo "✅ Bluebird Hotel app deployed. Visit http://$PUBLIC_IP/"
