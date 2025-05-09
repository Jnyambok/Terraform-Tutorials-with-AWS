# Terraform Configuration for EC2 Instance Deployment

This README provides a detailed explanation of the provided Terraform configuration, which deploys an EC2 instance on AWS. It covers the core concepts of EC2 and explains each block of code.

## Prerequisites

Before using this Terraform configuration, ensure you have the following:

* **Terraform installed:** Follow the official Terraform documentation for installation instructions: [https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install)
* **AWS Account:** You need an active AWS account.
* **AWS Credentials:** Configure your AWS credentials so Terraform can manage resources in your account. The most common methods are:
    * **Environment Variables:** Set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.
    * **`aws configure`:** Use the AWS CLI to configure your credentials by running `aws configure` and providing your access key ID, secret access key, region, and output format.
* **SSH Key Pair:** An SSH key pair is required to connect to the EC2 instance. You can create one in the AWS Management Console or using the AWS CLI. The private key file (`.pem` file) must be stored securely, and you'll need its path.

## Understanding Amazon EC2

Amazon Elastic Compute Cloud (EC2) is a fundamental part of AWS that provides scalable computing capacity in the cloud. Essentially, it allows you to rent virtual servers (called "instances") to run your applications.

**Key EC2 Concepts:**

* **Instance:** A virtual server in the AWS cloud.
* **Amazon Machine Image (AMI):** A template that contains the operating system, application server, and applications for your instance.
* **Instance Type:** Determines the hardware configuration of your instance, including CPU, memory, storage, and network capacity (e.g., `m5.large`).
* **Security Group:** A virtual firewall that controls inbound and outbound traffic for your instance.
* **Key Pair:** Used to securely log in to your instance via SSH.
* **Root Volume:** The boot volume for your EC2 instance.
* **Region:** AWS Regions are separate geographic areas. Instances are launched in a specific Region.

## Terraform Configuration Breakdown

The provided Terraform configuration consists of two main resources:

1.  `aws_instance`: Defines the EC2 instance.
2.  `aws_security_group`: Defines the security group for the EC2 instance.

Here's a breakdown of the code:

    terraform
    provider "aws" {
    region = "eu-north-1"
    }

* **`provider "aws"`:** This block configures the AWS provider, which allows Terraform to interact with AWS.
* **`region = "eu-north-1"`:** Specifies the AWS Region where the resources will be created. In this case, it's the `eu-north-1` (Stockholm) Region. You can change this to another region if needed.

    terraform
    resource "aws_instance" "web\_server" {
    ami = "ami-0e5482f75bed66741"
    instance\_type = "m5.large"
    tags = {
    Name = "julius\_ec2"
    Type = "web"
    }
    root\_block\_device {
    volume\_size = 8
    delete\_on\_termination = true
    }
    provisioner "remote-exec" {
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
    private\_key = file("<your-location-here>") ##Add your private key file location
    host = self.public\_ip
    }
    }
    vpc\_security\_group\_ids = [aws\_security\_group.web\_sg.id]
    }

* **`resource "aws_instance" "web_server"`:** This block defines an EC2 instance resource.
    * **`ami = "ami-0e5482f75bed66741"`:** Specifies the Amazon Machine Image (AMI) to use for the instance. AMIs vary by region and operating system. This AMI ID is for an Amazon Linux 2 AMI in the `eu-north-1` region. If you change the region, you'll need to find the appropriate AMI ID for that region. You can find AMIs using the AWS Management Console or the AWS CLI.
    * **`instance_type = "m5.large"`:** Specifies the instance type. `m5.large` provides a balance of compute, memory, and networking resources. Choose an instance type based on your application's needs.
    * **`tags`:** Assigns tags to the instance. Tags are key-value pairs that help you organize and manage your AWS resources.
        * `Name = "julius_ec2"`: Sets the name of the instance to "julius\_ec2". This is a user-defined name.
        * `Type = "web"`: Assigns a type tag with the value "web".
    * **`root_block_device`:** Configures the root volume (the boot volume) of the instance.
        * `volume_size = 8`: Sets the size of the root volume to 8 GB.
        * `delete_on_termination = true`: Specifies that the root volume should be deleted when the instance is terminated. This is often a good practice to avoid leaving behind orphaned volumes.
    * **`provisioner "remote-exec"`:** A provisioner is used to execute commands on the EC2 instance after it is created. The `remote-exec` provisioner connects to the instance via SSH and runs the specified commands.
        * `inline`: A list of commands to execute.
            * `"sudo yum update -y"`: Updates the package manager and all installed packages on the instance (for Amazon Linux).
            * `"sudo yum install -y httpd"`: Installs the Apache HTTP Server.
            * `"sudo systemctl start httpd"`: Starts the Apache HTTP Server.
            * `"sudo bash -c 'echo \"I made it! This is awesome!\" > /var/www/html/index.html'"`: Creates a simple HTML file (`index.html`) with the content "I made it! This is awesome!" This file will be served by the Apache web server.
            * `"sudo systemctl enable httpd"`: Configures the Apache HTTP Server to start automatically on system boot.
        * `connection`: Configures how Terraform connects to the instance.
            * `type = "ssh"`: Specifies that the connection type is SSH.
            * `user = "ec2-user"`: The default username for Amazon Linux 2 instances. This may vary for other operating systems.
            * `private_key = file("<your-location-here>")`: The path to your SSH private key file (`.pem` file). **You must replace `<your-location-here>` with the actual path to your key file.** Ensure this file has the correct permissions (e.g., `chmod 400 your-private-key.pem`).
            * `host = self.public_ip`: The hostname or IP address to connect to. `self.public_ip` is a special attribute that refers to the public IP address of the EC2 instance being created.
    * `vpc_security_group_ids = [aws_security_group.web_sg.id]`: Attaches the security group defined in the `aws_security_group` resource to the EC2 instance. This controls network traffic to and from the instance.

    terraform
    resource "aws_security_group" "web\_sg" {
    name = "web\_sg"
    description = "Security Group for web server"
    ingress {
    from\_port = 80
    to\_port = 80
    protocol = "tcp"
    cidr\_blocks = ["0.0.0.0/0"]
    }
    }

* **`resource "aws_security_group" "web_sg"`:** This block defines a security group named "web\_sg".
    * **`name = "web_sg"`:** The name of the security group.
    * **`description = "Security Group for web server"`:** A description of the security group.
    * **`ingress`:** Defines the inbound rules for the security group.
        * `from_port = 80`: Allows traffic from port 80.
        * `to_port = 80`: Allows traffic to port 80.
        * `protocol = "tcp"`: Specifies the TCP protocol.
        * `cidr_blocks = ["0.0.0.0/0"]`: Allows traffic from any IP address (0.0.0.0/0). **Warning:** In a production environment, you should restrict this to only allow traffic from known sources for security reasons.

## Key Points

* **AMI Selection:** The AMI determines the operating system of your EC2 instance. Choose an AMI that meets your requirements (e.g., Amazon Linux 2, Ubuntu, etc.). Ensure the AMI is in the same region as your instance.
* **Instance Type Selection:** The instance type determines the hardware resources allocated to your instance. Select an instance type based on your application's CPU, memory, storage, and network needs.
* **Security Groups:** Security groups are essential for controlling network access to your EC2 instance. Configure them carefully to allow only the necessary traffic. In this example, we're allowing HTTP traffic (port 80) from anywhere, which is suitable for a basic web server but should be restricted in production.
* **Provisioners:** Provisioners (like `remote-exec`) are used to perform actions on the instance after it's created. They should be used sparingly for initial setup or bootstrapping. For more complex configuration management, consider using tools like Ansible, Chef, or Puppet.
* **Root Volume:** The root volume is where the operating system is stored. You can specify its size and whether it should be deleted when the instance is terminated.
* **Regions:** AWS resources are deployed in specific regions. Choose a region that is geographically close to your users or that meets your compliance requirements.

## How to Use This Configuration

1.  **Save the code:** Save the Terraform code into a file named `main.tf`.
2.  **Initialize the project:** Run `terraform init` in the same directory as the `main.tf` file.
3.  **Plan the changes:** Run `terraform plan` to see what Terraform will do.
4.  **Apply the configuration:** Run `terraform apply` to create the EC2 instance and security group. You'll be prompted to confirm the changes.
5.  **Connect to the instance:** Use the SSH command provided by Terraform to connect to your EC2 instance. Remember to replace the placeholder with the actual path to your private key file.
6.  **Verify:** Open a web browser and navigate to the public IP address of the instance to see the "I made it! This is awesome!" message.

This configuration provides a basic setup for an EC2 web server. You can modify it to suit your specific needs, such as installing different software, configuring storage, and setting up networking.
