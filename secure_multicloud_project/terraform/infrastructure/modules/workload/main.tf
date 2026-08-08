# AWS KMS Key for Storage Encryption
resource "aws_kms_key" "workload" {
  description             = "KMS key for multi-cloud workload EBS and secrets encryption"
  deletion_window_in_days = 14
  enable_key_rotation     = true

  tags = {
    Name = "${var.name_prefix}-kms"
  }
}

resource "aws_kms_alias" "workload" {
  name          = "alias/${var.name_prefix}-kms"
  target_key_id = aws_kms_key.workload.key_id
}

# AWS Secrets Manager Secret for DB credentials
resource "aws_secretsmanager_secret" "database" {
  name                    = "${var.name_prefix}/database/credentials"
  kms_key_id              = aws_kms_key.workload.arn
  recovery_window_in_days = 7

  tags = {
    Name = "${var.name_prefix}-database-secret"
  }
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = var.database_username
    password = var.database_password
    database = var.database_name
  })
}

# IAM Role for Workload Instances
resource "aws_iam_role" "workload" {
  name = "${var.name_prefix}-workload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.workload.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "workload" {
  name = "${var.name_prefix}-workload-profile"
  role = aws_iam_role.workload.name
}

# SSH Key Pair (ED25519)
resource "tls_private_key" "lab" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "lab" {
  key_name   = "${var.name_prefix}-key"
  public_key = tls_private_key.lab.public_key_openssh
}

# 1. AWS Database Tier Instance (PostgreSQL)
resource "aws_instance" "database" {
  ami                  = var.ami_id
  instance_type        = var.aws_instance_type
  subnet_id            = var.db_subnet_id
  vpc_security_group_ids = [var.database_security_group_id]
  iam_instance_profile = aws_iam_instance_profile.workload.name

  associate_public_ip_address = false

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.workload.arn
    volume_type = "gp3"
    volume_size = 12
  }

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib awscli jq
    
    PG_VERSION="$(ls /etc/postgresql | sort -V | tail -1)"
    sed -i "s/^#listen_addresses.*/listen_addresses = '*'/" "/etc/postgresql/$${PG_VERSION}/main/postgresql.conf"
    echo "host ${var.database_name} ${var.database_username} 10.10.30.0/23 scram-sha-256" >> "/etc/postgresql/$${PG_VERSION}/main/pg_hba.conf"
    systemctl restart postgresql
  EOT

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.name_prefix}-database"
    Tier = "Database"
  }
}

# 2. AWS Application Tier Instance (Flask API)
resource "aws_instance" "application" {
  ami                  = var.ami_id
  instance_type        = var.aws_instance_type
  subnet_id            = var.app_subnet_id
  vpc_security_group_ids = [var.application_security_group_id]
  iam_instance_profile = aws_iam_instance_profile.workload.name

  associate_public_ip_address = false

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.workload.arn
    volume_type = "gp3"
    volume_size = 10
  }

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-venv postgresql-client curl jq awscli iperf3
    
    mkdir -p /opt/multicloud-app
    python3 -m venv /opt/multicloud-app/venv
    /opt/multicloud-app/venv/bin/pip install flask psycopg2-binary requests gunicorn

    cat > /opt/multicloud-app/app.py <<'PYTHON'
import os
import requests
from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/health")
def health():
    return jsonify({"service": "aws-application-tier", "status": "healthy"})

@app.get("/azure-health")
def azure_health():
    endpoint = os.environ.get("AZURE_SERVICE_URL", "http://10.20.10.10:8080/health")
    try:
        r = requests.get(endpoint, timeout=5)
        return jsonify({"azure_status_code": r.status_code, "azure_response": r.json()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PYTHON

    cat > /etc/systemd/system/multicloud-app.service <<'SERVICE'
[Unit]
Description=AWS Multi-Cloud Application Service
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/multicloud-app
ExecStart=/opt/multicloud-app/venv/bin/gunicorn --bind 0.0.0.0:8080 app:app
Restart=always
Environment=AZURE_SERVICE_URL=http://10.20.10.10:8080/health

[Install]
WantedBy=multi-user.target
SERVICE

    systemctl daemon-reload
    systemctl enable --now multicloud-app
  EOT

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.name_prefix}-application"
    Tier = "Application"
  }
}

# 3. AWS Web Tier Instance (Nginx Reverse Proxy)
resource "aws_instance" "web" {
  ami                  = var.ami_id
  instance_type        = var.aws_instance_type
  subnet_id            = var.web_subnet_id
  vpc_security_group_ids = [var.web_security_group_id]
  iam_instance_profile = aws_iam_instance_profile.workload.name

  associate_public_ip_address = false

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.workload.arn
    volume_type = "gp3"
    volume_size = 10
  }

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl

    cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    location / {
        proxy_pass http://${aws_instance.application.private_ip}:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX

    nginx -t
    systemctl enable --now nginx
  EOT

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.name_prefix}-web"
    Tier = "Web"
  }

  depends_on = [aws_instance.application]
}

# 4. AWS Application Load Balancer (Public Entrance)
resource "aws_lb" "web" {
  name               = substr("${var.name_prefix}-alb", 0, 32)
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_security_group_id]
  subnets            = [var.public_subnet_a_id, var.public_subnet_b_id]

  drop_invalid_header_fields = true

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = substr("${var.name_prefix}-web-tg", 0, 32)
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_instance.web.vpc_security_group_ids[0] # or pass vpc_id directly

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# 5. Azure Supporting Service Node (Virtual Machine)
resource "azurerm_network_interface" "azure_service" {
  name                = "nic-${var.name_prefix}-service"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.azure_service_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.10.10"
  }

  tags = var.common_tags
}

resource "tls_private_key" "azure_service" {
  algorithm = "ED25519"
}

resource "azurerm_linux_virtual_machine" "azure_service" {
  name                = "vm-${var.name_prefix}-service"
  computer_name       = "azureservice"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  size                = var.azure_vm_size
  admin_username      = "azureadmin"

  network_interface_ids = [azurerm_network_interface.azure_service.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureadmin"
    public_key = tls_private_key.azure_service.public_key_openssh
  }

  os_disk {
    name                 = "osdisk-${var.name_prefix}-service"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
    package_update: true
    packages:
      - python3
      - python3-pip
      - python3-venv
      - iperf3
      - curl
      - jq

    write_files:
      - path: /opt/azure-service/app.py
        permissions: "0644"
        content: |
          from flask import Flask, jsonify
          import socket, datetime
          app = Flask(__name__)
          @app.get("/health")
          def health():
              return jsonify({
                  "service": "azure-supporting-service",
                  "status": "healthy",
                  "host": socket.gethostname(),
                  "timestamp": datetime.datetime.utcnow().isoformat() + "Z"
              })

      - path: /etc/systemd/system/azure-service.service
        permissions: "0644"
        content: |
          [Unit]
          Description=Azure Multi-Cloud Supporting Service
          After=network-online.target
          [Service]
          Type=simple
          WorkingDirectory=/opt/azure-service
          ExecStart=/opt/azure-service/venv/bin/gunicorn --bind 0.0.0.0:8080 app:app
          Restart=always
          [Install]
          WantedBy=multi-user.target

    runcmd:
      - mkdir -p /opt/azure-service
      - python3 -m venv /opt/azure-service/venv
      - /opt/azure-service/venv/bin/pip install flask gunicorn
      - systemctl daemon-reload
      - systemctl enable --now azure-service
      - iperf3 -s -D
  CLOUDINIT
  )

  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}
