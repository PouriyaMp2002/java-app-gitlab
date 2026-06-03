# Java Petclinic DevOps Project

A DevOps-focused Java web application project based on the Spring Framework Petclinic application.

The purpose of this repository is to demonstrate a complete CI/CD workflow for building, testing, scanning, containerizing, and deploying a Java application using Maven, Docker, SonarQube, Trivy, GitLab CI/CD, Terraform, AWS ECR, and AWS ECS.

---

## Project Overview

This project contains a Java Spring MVC application packaged as a WAR file and deployed on Apache Tomcat.

The repository also includes DevOps automation for:

- Building and testing a Java Maven application
- Packaging the application as a WAR file
- Running static code analysis with SonarQube
- Scanning artifacts and Docker images with Trivy
- Building a Docker image
- Pushing the Docker image to AWS ECR
- Deploying the application to AWS ECS

The project also includes supporting DevOps setup and infrastructure components: 

- Provisioning infrastructure using Terraform
- Running SonarQube locally using Docker Compose

---

## Repository Structure

```text
.
├── src/                    # Java application source code and tests
├── sonarqube/              # Local SonarQube setup using Docker Compose
├── terraform/              # AWS infrastructure provisioning files
├── Dockerfile              # Docker image definition for Tomcat deployment
├── .gitlab-ci.yml          # CI/CD pipeline definition
├── pom.xml                 # Maven project configuration
├── mvnw                    # Maven wrapper for Linux/macOS
├── mvnw.cmd                # Maven wrapper for Windows
├── .gitignore              # Files and folders ignored by Git
└── README.md               # Project documentation
```

---

## Application Build

The project uses Maven to compile, test, and package the application.

```bash
mvn clean package
```

After a successful build, Maven creates a WAR file inside the `target/` directory:

```text
target/petclinic.war
```

The `target/` folder is generated automatically and should not be pushed to GitHub.

---

## Run the Application with Docker

First build the WAR file:

```bash
mvn clean package
```

Then build the Docker image:

```bash
docker build -t java-app .
```

Run the container:

```bash
docker run -d -p 8080:8080 --name petclinic java-app
```

Open the application:

```text
http://localhost:8080
```

---

## CI/CD Pipeline Explanation

This project uses a **GitLab CI/CD pipeline** to automate the process of building, checking, containerizing, and deploying the Java application.

The pipeline is configured on a **self-hosted GitLab** instance and runs using a **GitLab Runner**. This setup provides more control over the CI/CD environment, runner configuration, execution resources, and integration with external tools such as Docker, AWS, SonarQube, and Trivy.

When new code is pushed to the repository, the pipeline starts automatically and runs the application through several stages before deployment.

### Pipeline Flow 

```text
Code Push
   ↓
Build Java Application
   ↓
Run Tests
   ↓
Analyze Code with SonarQube
   ↓
Scan Files with Trivy
   ↓
Build Docker Image
   ↓
Scan Docker Image
   ↓
Push Image to AWS ECR
   ↓
Deploy New Version to AWS ECS
```

---

### Build and Test

The pipeline first uses **Maven** to compile the Java application, run tests, and package the project as a WAR file.

### Code Quality Analysis

After the build, the pipeline runs **SonarQube analysis** to check the quality of the source code.

SonarQube helps detect:

- Bugs
- Code smells
- Duplicated code
- Maintainability issues
- Possible security problems

If a **quality gate** is configured, the pipeline can stop when the code does not meet the required standard.

### Security Scanning

The pipeline uses **Trivy** to scan the project files and Docker image for known vulnerabilities.

This adds a **DevSecOps** step before deployment and helps prevent insecure artifacts or container images from being released.

### Docker Image Build

After the application passes the quality and security checks, the pipeline builds a Docker image.

The Docker image uses *Apache Tomcat* as the runtime environment and copies the generated *petclinic.war* file into the Tomcat webapps directory as *ROOT.war*.

### Push to AWS ECR (Elastic Container Registry)

Once the Docker image is built and scanned, it is tagged and pushed to AWS Elastic Container Registry.

ECR stores the Docker image so it can be pulled later by AWS ECS during deployment.

Using image tags, such as the **Git commit SHA or pipeline build number**, makes it possible to track which version of the code is running in each deployment.

### Deploy to AWS ECS (Elastic Container Service)

In the final stage, the pipeline updates **the AWS ECS service** with the *new Docker* image from **ECR**.

ECS creates a new task definition revision, pulls **the latest image** from ECR, starts new containers, and replaces the old running version of the application.

This completes the automated flow from source code to running application in AWS.

---

## Required AWS Resources

To deploy this project to AWS ECS, the following resources are usually required:

- ECR repository
- ECS cluster
- ECS task definition
- ECS service
- IAM role for ECS task execution
- VPC
- Subnets
- Security group
- Optional Application Load Balancer
- CloudWatch logs

Some of these resources can be created manually, while others can be provisioned using Terraform.
 
---

## Required CI/CD Variables

The following variables should be configured in the CI/CD platform before running the pipeline:

| Variable | Description |
|---|---|
| `SONAR_HOST_URL` | SonarQube server URL |
| `SONAR_TOKEN` | SonarQube authentication token |
| `ECR_REGISTRY` | AWS ECR registry URL |
| `ECR_REPO` | AWS ECR repository name |
| `AWS_REGION` | AWS region |
| `ECS_CLUSTER` | ECS cluster name |
| `ECS_SERVICE` | ECS service name |
| `ECS_TASK_DEFINITION` | ECS task definition name |
| `ECS_CONTAINER` | ECS container name inside the task definition |
| `AWS_ACCESS_KEY_ID` | AWS access key for deployment |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for deployment |

Sensitive values should always be stored as protected or masked CI/CD variables.

Do not commit credentials to the repository.

---

## SonarQube Setup

The `sonarqube/` directory contains a Docker Compose setup for running SonarQube locally or on a server.

```text
sonarqube/
├── docker-compose.yml
├── install.sh
└── .env.example
```

To use it:

```bash
cd sonarqube
cp .env.example .env
docker compose up -d
```

SonarQube will be available at:

```text
http://localhost:9000
```

---

## Infrastructure with Terraform

The `terraform/` directory contains Infrastructure as Code configuration for AWS resources used in the DevOps environment.

Current Terraform files include configuration for:

- AWS provider
- EC2 instances
- Security groups
- Backend configuration
- Input variables
- Outputs

Basic Terraform workflow:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Before applying Terraform, update the required variables according to your AWS environment.

---

## ECS Configuration

### Step 1: Create an ECR Repository

The ECR repository was created earlier, so this project already has a repository available for storing Docker images.

### Step 2: Create an ECS Cluster

Go to:

**AWS Console → Amazon ECS → Clusters → Create cluster**

Create a cluster with the following configuration:

| Setting | Value |
|---|---|
| Cluster name | `java-app-cluster` |
| Infrastructure | AWS Fargate |

After creating the cluster, ECS will use this cluster to run the service.


### Step 3: Create a Task Definition

Go to:

**AWS Console → Amazon ECS → Task definitions → Create new task definition**

Use the following configuration:

| Setting | Value |
|---|---|
| Task definition family | `java-app-task` |
| Launch type | AWS Fargate |
| Operating system | Linux |
| CPU | 0.5 vCPU |
| Memory | 1 GB |


### Step 4: Container Configuration

Add a container with the following settings:

| Setting | Value |
|---|---|
| Container name | `java-app-container` |
| Image URI | `123456789012.dkr.ecr.us-east-1.amazonaws.com/...` |
| Container port | `8080` |
| Protocol | TCP |

*Image URI can be imported from ECR with "latest" tag.*

The image tag can be `latest` for the first manual setup.

Then, the GitLab pipeline will replace this image with the pipeline image tag, for example:

123456789012.dkr.ecr.us-east-1.amazonaws.com/**petclinic:v25**

---

### Step 5: Security Groups

You need two security groups:

1. Load Balancer Security Group
2. ECS Service Security Group

### Load Balancer Security Group

This security group allows users to access the application through HTTP.

#### Inbound Rules

| Type | Protocol | Port | Source |
|---|---|---:|---|
| HTTP | TCP | 80 | `0.0.0.0/0` |

| Type | Protocol | Port | Source |
|---|---|---:|---|
| HTTPS | TCP | 443 | `0.0.0.0/0` |

#### Outbound Rules

| Type | Destination |
|---|---|
| All traffic | `0.0.0.0/0` |


### ECS Service Security Group

This security group allows traffic from the load balancer to the ECS container.

#### Inbound Rules

| Type | Protocol | Port | Source |
|---|---|---:|---|
| Custom TCP | TCP | 8080 | Load Balancer Security Group |

#### Outbound Rules

| Type | Destination |
|---|---|
| All traffic | `0.0.0.0/0` |


This means users cannot directly access the ECS task. Traffic must go through the Application Load Balancer.

### Step 6: Create a Target Group

Go to:

**AWS Console → EC2 → Target Groups → Create target group**

Use the following configuration:

| Setting | Value |
|---|---|
| Target type | IP addresses |
| Target group name | `java-app-tg` |
| Protocol | HTTP |
| Port | 8080 |
| VPC | Select your VPC |

For ECS Fargate, use:

```text
Target type: IP addresses
```

#### Health Check Configuration

Use:

| Setting | Value |
|---|---|
| Protocol | HTTP |
| Path | `/` |
| Port | traffic port |
| Success codes | `200` |

Because this project deploys the WAR as `ROOT.war`, the application should be available from:

```text
/
```

If `/` does not return `200`, you can use another working path from the application.


### Step 7: Create an Application Load Balancer

Go to:

**AWS Console → EC2 → Load Balancers → Create load balancer**

Choose:

```text
Application Load Balancer
```

Use this configuration:

| Setting | Value |
|---|---|
| Load balancer name | `java-app-alb` |
| Scheme | Internet-facing |
| IP address type | IPv4 |
| VPC | Select your VPC |
| Subnets | Select at least two public subnets |
| Security group | Load Balancer Security Group |

Create a listener:

| Setting | Value |
|---|---|
| Protocol | HTTP |
| Port | 80 |
| Default action | Forward to `java-app-tg` |


### Step 8: Create an ECS Service

Go to:

**AWS Console → Amazon ECS → Clusters → java-app-cluster → Services → Create**

Use the following configuration:

| Setting | Value |
|---|---|
| Compute option | Launch type |
| Launch type | Fargate |
| Task definition | `java-app-task` |
| Service name | `java-app-service` |
| Desired tasks | 1 |

#### Networking Configuration

Select:

| Setting | Value |
|---|---|
| VPC | Your application VPC |
| Subnets | Public subnets or private subnets |
| Security group | **ECS Service Security Group** |

If using public subnets: Enable Auto-assign public IP

#### Load Balancer Configuration

Attach the service to the Application Load Balancer:

| Setting | Value |
|---|---|
| Load balancer type | Application Load Balancer |
| Load balancer | `java-app-alb` |
| Container | `java-app-container` |
| Container port | 8080 |
| Target group | `java-app-tg` |

Create the service.

ECS will start the task and register it with the target group.

### Step 9: Confirm the Application is Running

Go to:

**EC2 → Target Groups → java-app-tg → Targets**

Wait until the target status becomes:

```text
Healthy
```

Open the load balancer DNS name in the browser:

```text
http://java-app-alb-123456789.us-east-1.elb.amazonaws.com
```

The Petclinic application should be visible.

---

**The IAM user configured for GitLab must have the required permissions to push Docker images to Amazon ECR and deploy new revisions to Amazon ECS. For a learning project, permissions such as ECR push access and AmazonECS_FullAccess can be used. For production environments, a least-privilege IAM policy is recommended.**

---

This project demonstrates a real-world DevOps workflow for deploying a Java application to the cloud. The goal is to show how modern DevOps practices can be applied to automate the software delivery lifecycle from source code to production deployment.

The pipeline includes build automation, unit testing, code quality checks, security scanning, Docker containerization, image publishing to AWS ECR, and deployment to AWS ECS Fargate.