# Terraform-Tutorials-with-AWS
![image](https://github.com/user-attachments/assets/bf40c6d3-6f07-4334-80cb-22eae714ce23)

![image](https://github.com/user-attachments/assets/24312d8f-99b5-4852-af87-e07cfaf4e845)



This repo contains Terraform reusable code snippets that can be reused to launch resources.


# Deploying an EC2 Instance with Terraform

This README provides the steps to deploy an EC2 instance using the provided Terraform configuration.

## Prerequisites

Before you begin, ensure you have the following:

* **Terraform installed:** Follow the instructions in this Medium article to set up Terraform: [here](https://medium.com/towards-artificial-intelligence/building-a-robust-and-efficient-aws-cloud-infrastructure-with-terraform-and-gitlab-ci-cd-925ff592ad46)
* **AWS Account:** You'll need an active AWS account.
* **AWS Credentials:** Configure your AWS credentials so Terraform can manage your account's resources. You can use environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) or the `aws configure` command.
* **SSH Key Pair:** An SSH key pair is required to connect to the EC2 instance. If you don't have one, create it in the AWS Management Console or using the AWS CLI. **Important:** Store the private key file (`.pem` file) in a secure location, and you'll need its path.

## Steps to Deploy

1.  **Clone the repository (if applicable):** If you have this Terraform configuration in a Git repository, clone it to your local machine:

    ```bash
    git clone <your-repository-url>
    cd <your-repository-directory>
    ```

2.  **Create a Terraform configuration file:** If you haven't already, save the provided Terraform code into a file named `main.tf`.

3.  **Initialize the Terraform project:**

    ```bash
    terraform init
    ```

    This command initializes the Terraform working directory. It downloads the necessary provider plugins (in this case, the AWS provider).

4.  **Review the Terraform plan:**

    ```bash
    terraform plan
    ```

    This command shows you the changes that Terraform will make to your AWS environment. It's a good practice to review the plan carefully before applying any changes.

5.  **Apply the Terraform configuration:**

    ```bash
    terraform apply
    ```

    This command applies the changes described in the Terraform plan. Terraform will create the EC2 instance and the security group. You'll be prompted to confirm the changes before they are applied. Type `yes` and press Enter to proceed.

6.  **Access the EC2 Instance:**

    * Once the deployment is complete, Terraform will output the public IP address of the EC2 instance.
    * To connect to the instance via SSH, use the following command:

        ```bash
        ssh -i <path-to-your-private-key.pem> ec2-user@<your-instance-public-ip>
        ```

        Replace `<path-to-your-private-key.pem>` with the actual path to your private key file, and `<your-instance-public-ip>` with the public IP address of your EC2 instance.

7.  **Verify the web server:**

    * Open a web browser and navigate to the public IP address of your EC2 instance (e.g., `http://<your-instance-public-ip>`).
    * You should see the message "I made it! This is awesome!"

## Destroying the Infrastructure

To destroy the resources created by Terraform (the EC2 instance and the security group), use the following command:

```bash
terraform destroy
