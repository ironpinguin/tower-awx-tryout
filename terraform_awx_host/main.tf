provider "aws" {
  access_key = "${var.aws_accesskey}"
  secret_key = "${var.aws_secretkey}"
  region     = "eu-central-1"
}

data "aws_route53_zone" "aws_grayflowr_zone" {
  name = "${var.aws_dns_zone}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "awx_host" {
  name = "awx_host_access"
  description = "allow http/https and ssh access form every where"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name = "awx docker host"
  }
}


resource "aws_instance" "awx" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.medium"
  key_name = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.awx_host.name}"]
  root_block_device {
        volume_size = 30
  }
  tags {
    Name = "awx-try"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install -y python python-apt apt-transport-https ca-certificates curl software-properties-common git",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
    }
  }
}

resource "aws_route53_record" "awx_host" {
  zone_id = "${data.aws_route53_zone.aws_grayflowr_zone.zone_id}"
  name = "awx.${data.aws_route53_zone.aws_grayflowr_zone.name}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.awx.public_ip}"]
}

output "hostname" {
  value = "awx.${data.aws_route53_zone.aws_grayflowr_zone.name}"
}
