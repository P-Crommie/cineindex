
# CineIndex - Flask Application

CineIndex is a Flask application that has been Dockerized and deployed to a Kubernetes cluster using a Helm chart. Cineindex saves your favorite actors with their movie catelog.


## Requirements

    • Docker
    • Helm
    • AWS CLI and IAM User with permissions to access ECR
    • kubectl
    • A running Kubernetes cluster
## Building the Docker Image

1. Clone the repository
git clone http://crommie.chickenkiller.com:8088/root/cineindex.git

2. Navigate to the repository folde
cd cineindex

3. Build the Docker image using the following command
docker build -t <image_name> .

4. Login to your AWS account and push the image to ECR using the following commands:
- aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 644435390668.dkr.ecr.us-west-2.amazonaws.com
- docker tag cromwell-cineindex:latest 644435390668.dkr.ecr.us-west-2.amazonaws.com/cromwell-cineindex:latest
- docker push 644435390668.dkr.ecr.us-west-2.amazonaws.com/cromwell-cineindex:latest

## Deploying to Kubernetes
1. Add the ECR Helm repository using the following command
- helm repo add cineindex 644435390668.dkr.ecr.us-west-2.amazonaws.com/cineindex

2. Install the Helm chart using the following command
- helm install <release_name> cineindex/cineindex

3. Verify that the pods are running using the following command
- kubectl get pods

## Updating the Application
1. Repeat the steps for building the Docker image

2. Update the Helm release using the following command
- helm upgrade <release_name> <repo_name>/cineindex

3. Verify that the pods are updated using the following command
- kubectl get pods

## Note
The values.yml file and the commands in this document should be modified to match the specific configuration of your application and infrastructure.