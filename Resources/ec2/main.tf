provider "aws" {
    region = "eu-north-1"
}

resource "aws_instance" "web_server" {
    ami = "ami-0e5482f75bed66741"
    instance_type = "m5.large"

    tags = {
        Name = "julius_ec2"
        Type = "web"

    }

    root_block_device {
        volume_size = 8
        delete_on_termination = true
    }

    provisioner "remote-exec"{
        inline = [
            "sudo yum update -y",
            "sudo yum install -y httpd",
            "sudo systemctl start httpd",
            "sudo bash -c 'echo \"I made it! This is awesome!\" > /var/www/html/index.html'",
            "sudo systemctl enable httpd"

        ]

        connection {
            type = "ssh"
            user = "ec2-user"
            private_key = file("<your-location-here>")  ##Add your private key file location
            host = self.public_ip
        }
    }

    vpc_security_group_ids = [aws_security_group.web_sg.id]

}


resource "aws_security_group" "web_sg" {
    name = "web_sg"
    description = "Security Group for web server"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
