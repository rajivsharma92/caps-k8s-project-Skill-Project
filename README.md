### End-to-End DevOps Pipeline for AWS EKS Deployment
This project implements a fully automated CI/CD pipeline to provision AWS infrastructure using Terraform and deploy a containerized application (with monitoring via Prometheus) onto an AWS EKS cluster using Kubernetes. All deployments and cleanups are fully automated via three separate Jenkins pipelines.
# Architecture Diagram
Below is the architecture diagram of the deployment:
![image](https://github.com/user-attachments/assets/4a35e05b-b069-4c4c-a903-3a92a25a0013)

1. Overview
Project Components
- Terraform Infrastructure Provisioning
The infrastructure is provisioned using Terraform with Terraform state stored and backed up in an S3 bucket. This repository provisions the AWS EKS cluster, VPC, subnets, and IAM roles.
- Kubernetes Deployment
The Kubernetes manifests and deployment scripts are stored in a separate repository. The deploy.sh script located in the scripts folder deploys all required resources:
- Creation of the Kubernetes namespace.
- Application of secrets and configuration (including Prometheus configuration).
- Deployment of backend (careerpath) and frontend services.
- Deployment of monitoring tools (Prometheus and cAdvisor) for real-time monitoring.
- Deployment of ingress resources.
- Jenkins Pipelines
Three distinct Jenkins pipelines automate the complete workflow:
- Terraform Deployment Pipeline: Clones the Terraform repository, initializes, validates, and applies Terraform configuration to provision the AWS infrastructure.
- Kubernetes Deployment Pipeline: Clones the Kubernetes repository and executes the deployment script (deploy.sh), which deploys all the Kubernetes resources (including monitoring and ingress).
- Cleanup Pipeline: Clones the Kubernetes repository and executes a cleanup script (cleanup.sh) that removes the deployed resources when needed.

2. System Architecture & Repository Structure
Repositories
- Terraform Repository
URL: https://github.com/rajivsharma92/terraform-caps-project.git
Role: Provisions the AWS EKS cluster, networking resources, and IAM roles using Terraform. All Terraform state files are stored in an S3 bucket for backup and disaster recovery.
- Kubernetes Deployment Repository
URL: https://github.com/rajivsharma92/caps-k8s-project-Skill-Project.git
Role: Contains all Kubernetes manifests and the scripts folder with:
- deploy.sh – Automates the deployment of the namespace, secrets, backend, frontend, monitoring components (Prometheus, cAdvisor), and ingress.
- cleanup.sh – Automates the deletion of all deployed resources.

3. Terraform Infrastructure Provisioning
Terraform provisions the AWS infrastructure required for the EKS cluster. The Terraform state is securely stored in an S3 bucket to ensure persistence and disaster recovery.
Deployment Process (Managed via Jenkins)
Jenkinsfile for Terraform Deployment
pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
    }

    stages {
        stage('Clone Terraform Repo') {
            steps {
                script {
                    sh 'rm -rf terraform-repo'
                    sh 'git clone https://github.com/rajivsharma92/terraform-caps-project.git terraform-repo'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    sh 'cd terraform-repo && terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                script {
                    sh 'cd terraform-repo && terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh 'cd terraform-repo && terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh 'cd terraform-repo && terraform apply -auto-approve'
                }
            }
        }

        stage('Verify Infrastructure') {
            steps {
                script {
                    sh 'aws eks describe-cluster --name caps-eks-cluster'
                }
            }
        }
    }
}


This pipeline provisions the EKS cluster along with the necessary networking and IAM policies, ensuring that the Terraform state is backed up on S3.

4. Kubernetes Deployment
The Kubernetes deployment pipeline deploys all applications and monitoring components using a preconfigured script (deploy.sh) from the repository’s scripts folder.
Deployment Process (Managed via Jenkins)
Jenkinsfile for Kubernetes Deployment
pipeline {
    agent any
    
    environment {
        KUBE_CONFIG = credentials('kube-config')
    }

    stages {
        stage('Clone Kubernetes Repo') {
            steps {
                script {
                    sh 'rm -rf k8s-repo'
                    sh 'git clone https://github.com/rajivsharma92/caps-k8s-project-Skill-Project.git k8s-repo'
                }
            }
        }

        stage('Execute Deployment Script') {
            steps {
                script {
                    sh 'cd k8s-repo/scripts && chmod +x deploy.sh && ./deploy.sh'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh 'kubectl get pods -n saleproject'
                    sh 'kubectl get svc -n saleproject'
                }
            }
        }
    }
}


The deploy.sh script performs the following operations:
- Namespace Creation: Applies namespace.yaml to create and set the default namespace (saleproject).
- Secrets & Prometheus Config: Applies secret.yaml and prometheus-configmap.yaml for secure configuration and monitoring.
- Application Deployment: Deploys backend (careerpath) and frontend services.
- Monitoring Deployment: Deploys Prometheus and cAdvisor (for monitoring cluster health) along with ingress resources.
- Verification: Prints deployed pods and services in the namespace.

5. Cleanup Pipeline
This pipeline provides an automated way to remove all deployed Kubernetes resources when needed.
Cleanup Process (Managed via Jenkins)
Jenkinsfile for Cleanup Deployment
pipeline {
    agent any
    
    environment {
        KUBE_CONFIG = credentials('kube-config')
    }
    
    stages {
        stage('Clone Kubernetes Repo') {
            steps {
                script {
                    sh 'rm -rf k8s-repo'
                    sh 'git clone https://github.com/rajivsharma92/caps-k8s-project-Skill-Project.git k8s-repo'
                }
            }
        }
        
        stage('Execute Cleanup Script') {
            steps {
                script {
                    sh 'cd k8s-repo/scripts && chmod +x cleanup.sh && ./cleanup.sh'
                }
            }
        }
        
        stage('Verify Cleanup') {
            steps {
                script {
                    sh 'kubectl get pods -n saleproject || echo "No pods found in saleproject namespace"'
                    sh 'kubectl get svc -n saleproject || echo "No services found in saleproject namespace"'
                }
            }
        }
    }
}


This pipeline clones the Kubernetes repository, runs the cleanup.sh script (which removes all deployed resources), and verifies that the namespace is cleared.

6. Verification & Validation
After executing the pipelines, verify the deployment using:
- AWS Infrastructure Verification:
aws eks describe-cluster --name caps-eks-cluster
- Kubernetes Resources Verification:
kubectl get pods -n saleproject
kubectl get svc -n saleproject


Collect logs and screenshots from Jenkins console outputs as evidence of successful execution.

7. Project Closure & Cleanup
When closing the project:
- Run the Cleanup Pipeline:
Use the third Jenkinsfile to execute the cleanup process and remove deployed Kubernetes resources.
- Optional Terraform Destruction:
If no further testing is needed, run the following command from the Terraform repository to destroy AWS resources:
terraform destroy -auto-approve
- Repository Archival:
Archive or set the repositories to private to secure your work for future audits.
- Cost Verification:
Ensure no unwanted AWS resources remain active by reviewing your AWS billing dashboard.
- Project Retrospective:
Document lessons learned and recommendations for future improvements.

8. Conclusion
This project demonstrates a robust, end-to-end automated pipeline using:
- Terraform (with S3 state backup): For provisioning infrastructure on AWS.
- Kubernetes: For deploying a fully containerized application with integrated monitoring (Prometheus and cAdvisor).
- Jenkins Pipelines: Three separate pipelines manage infrastructure deployment, application deployment, and cleanup.
All processes are automated to ensure reproducibility, quick recovery, and clear verification of each stage. This documentation, along with Jenkins logs and system screenshots, forms the basis for the final project closure.


