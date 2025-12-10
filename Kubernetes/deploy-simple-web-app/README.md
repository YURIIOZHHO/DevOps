## Deploy a Simple Web Application on Kubernetes

### Assignment description
### Using a Kubernetes cluster, launch a basic web application to get started. Utilise Docker to containerize a popular web server, like Nginx or Apache, and then host it on Kubernetes.
#### In this project, Amazon EKS was used to run the Kubernetes cluster.

#### 1. Installing Required Tools
##### Before creating a cluster, the following utilities must be installed:
##### - AWS CLI
##### - kubectl
##### - eksctl

!["installed utility"](https://github.com/user-attachments/assets/37122a13-6fe1-4b05-9c94-ec4c6dc92b12)


#### 2. Creating an EKS Cluster
##### To create the cluster and worker nodes, the following command was executed:
```
student@student-VirtualBox:~$ eksctl create cluster \
--name web \
--region eu-central-1 \
--nodegroup-name standerd-workers \
--node-type m7i-flex.large \
--nodes 1 \
--nodes-min 1 \
--nodes-max 2 \
```

#### 3. AWS Resources Created Automatically
##### After running the command, EKS automatically created all necessary components in AWS.
##### Below are the main resources visible in the AWS console: 

##### EKS Cluster
!["Cluster"](https://github.com/user-attachments/assets/2bbc3d2b-72bd-4a17-a700-136e556618a9)

##### Worker Node
!["Node"](https://github.com/user-attachments/assets/e056ec5f-a9fa-4774-a735-9eb1cb7c2722)

##### VPC
!["VPC"](https://github.com/user-attachments/assets/fa4253f1-576c-47de-807c-8a14bdfc47ac)

##### Subnets
!["Subnets"](https://github.com/user-attachments/assets/86c5bb87-c6e1-48d8-bcac-5776b49e013d)

##### Route Tables
!["Route tables"](https://github.com/user-attachments/assets/082184ba-c5fd-4238-80bc-a3b560059979)

##### IGW
!["IGW"](https://github.com/user-attachments/assets/625a9d70-40da-4fc5-bcb9-88d87cb87678)

##### SG
!["SG"](https://github.com/user-attachments/assets/e5a20a0a-83a7-4dc1-af01-2d373d9c7321)

##### IAM Roles
!["Roles"](https://github.com/user-attachments/assets/ef93dbfa-75ff-4e43-8f28-7bb8b0e34de5)
)
##### CloudFormation
!["CloudFormation"](https://github.com/user-attachments/assets/45000d74-f88a-4389-a0b5-965606e88df6)

##### NAT
!["NAT"](https://github.com/user-attachments/assets/e2a1e4c9-29fd-44f9-a23b-b1b6ccf2c291)

##### Elastic IP
!["Elastic IP"](https://github.com/user-attachments/assets/cda78f5a-2f09-4679-b889-19dfc9a1cfa9)

#### 4. Deploying the Application
##### A declarative approach was used to create the deployment and load balancer service.

`deployment.yaml`
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: my-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-nginx
  template:
    metadata:
      labels:
        app: my-nginx
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
```
`service.yaml`
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-public-service
spec:
  type: LoadBalancer
  selector:
    app: my-nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

#### 5. Application Running in the Cluster
##### Pods
!["Pods"](https://github.com/user-attachments/assets/a6828ab6-6091-4ca6-afd8-34fc55cb5085)

##### Domain
!["Domain"](https://github.com/user-attachments/assets/1c68c3a9-85e3-4b6c-a981-aeb01d2aa1e0)

##### Browser result
!["NGINX"](https://github.com/user-attachments/assets/952c625a-0fc4-4120-a4d6-90d6e1ad9420)


### Summary
#### - An EKS cluster was created using eksctl.
#### - All required AWS components were provisioned automatically.
#### - A Dockerized Nginx application was deployed using Kubernetes Deployment and Service manifests.
#### - The application became publicly accessible through an AWS LoadBalancer.


