# DevOps Engineer Assessment

## Overview
This document outlines the steps to complete the DevOps Engineer assessment. The tasks include setting up Jenkins, Dockerizing a Python app, pushing the Docker image to DockerHub, setting up a Kubernetes cluster, configuring ArgoCD, and deploying the Dockerized app securely.

## Prerequisites
- Windows OS
- Docker Desktop
- Git Bash
- PowerShell
- Minikube
- GitHub Account
- DockerHub Account
- Jenkins
- ArgoCD

## Steps

### 1. Spin up a Jenkins instance
1. **Install Jenkins:**
   - Download Jenkins from the [official website](https://www.jenkins.io/download/).
   - Install Jenkins using the installer.
   - Start Jenkins using PowerShell:
     ```sh
     java -jar jenkins.war
     ```
   - Access Jenkins at `http://localhost:8080`.

2. **Initial Setup:**
   - Follow the on-screen instructions to complete the initial setup.
   - Install suggested plugins.
   - Create an admin user.

### 2. Configure Jenkins to trigger a Build on commit
1. **Create a Jenkins Job:**
   - Create a new Freestyle project.
   - In the `Source Code Management` section, select `Git` and enter your repository URL.
   - In the `Build Triggers` section, select `Poll SCM` and set the schedule (e.g., `H/5 * * * *` for polling every 5 minutes).

### 3. Use Jenkinsfile to Dockerize the app and publish to DockerHub
1. **Create Jenkinsfile:**
   - Add a `Jenkinsfile` to your repository with the following content:
     ```groovy
     pipeline {
         agent any

         environment {
             DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials') // Ensure this ID matches your stored credentials ID
             DOCKERHUB_REPO = 'theodosp9/mypyapp'
             DOCKERHUB_TAG = 'latest'
         }

         stages {
             stage('Build Docker image') {
                 steps {
                     script {
                         // Build the Docker image
                         bat """pwd
                         docker build -t my-python-app:${env.BUILD_ID} ."""
                     }
                 }
             }

             stage('Run Docker container') {
                 steps {
                     script {
                         // Run the Docker container
                         bat "docker run -d --name my-python-app-${env.BUILD_ID} my-python-app:${env.BUILD_ID}"
                     }
                 }
             }

             stage('Login to DockerHub') {
                 steps {
                     script {
                         // Login to DockerHub
                         bat "docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}"
                     }
                 }
             }

             stage('Tag Docker image') {
                 steps {
                     script {
                         // Tag the Docker image
                         bat "docker tag my-python-app:${env.BUILD_ID} ${DOCKERHUB_REPO}:${DOCKERHUB_TAG}"
                     }
                 }
             }

             stage('Push Docker image') {
                 steps {
                     script {
                         // Push the Docker image to DockerHub
                         bat "docker push ${DOCKERHUB_REPO}:${DOCKERHUB_TAG}"
                     }
                 }
             }
         }

         post {
             always {
                 // Clean up workspace after the build
                 cleanWs()
             }
             success {
                 echo 'The build succeeded!'
             }
             failure {
                 echo 'The build failed!'
             }
         }
     }
     ```

2. **Configure DockerHub Credentials:**
   - In Jenkins, navigate to `Manage Jenkins` > `Manage Credentials`.
   - Add DockerHub credentials.

### 4. Spin up a Kubernetes cluster using Minikube
1. **Install Minikube:**
   - Download Minikube from the [official website](https://minikube.sigs.k8s.io/docs/start/).
   - Install Minikube using the installer.
   - Start Minikube:
     ```sh
     minikube start
     ```

### 5. Spin up an ArgoCD instance
1. **Install ArgoCD:**
   - Follow the [official guide](https://argo-cd.readthedocs.io/en/stable/getting_started/) to install ArgoCD.

2. **Access ArgoCD UI:**
   - Forward the ArgoCD server port:
     ```sh
     kubectl port-forward svc/argocd-server -n argocd 8010:443
     ```
   - Access the UI at `https://localhost:8010`.

### 6. Provision the Docker image on Kubernetes using ArgoCD
1. **Create ArgoCD Application:**
   - In the ArgoCD UI, create a new application.
   - Set the repository URL to your GitHub repository.
   - Set the path to the Kubernetes manifests.

2. **Kubernetes Manifests:**
   - Create a `deployment.yaml` and `service.yaml` for your app.
   - Ensure the deployment uses the Docker image from DockerHub.

### 7. Expose the deployment using Traefik
1. **Install Traefik:**
   - Follow the [official guide](https://doc.traefik.io/traefik/getting-started/install-traefik/) to install Traefik.

2. **Configure Traefik Ingress:**
   - Create an `IngressRoute` for your deployment.

### 8. Security Precautions
1. **Restrict Access:**
   - Configure network policies to restrict access to specific IPs.
   - Example Network Policy:
     ```yaml
     apiVersion: networking.k8s.io/v1
     kind: NetworkPolicy
     metadata:
       name: allow-specific-ips
       namespace: default
     spec:
       podSelector:
         matchLabels:
           app: hello-world
       policyTypes:
       - Ingress
       ingress:
       - from:
         - ipBlock:
             cidr: <your_ip>/32
     ```

## Conclusion
Following these steps, you will set up a CI/CD pipeline using Jenkins, Dockerize a Python app, deploy it on a Kubernetes cluster, and manage the deployment with ArgoCD. Ensure security by restricting access to specific IPs.
