# **DevOps hands-on project**.

## DevOps tools  used in this practice task:
- Git
- Bit Bucket
- Jenkins
- SonarQube
- Apache Archiva
- Ansible
- Docker
- Kubernetes
- Apache Tomcat

### 1. Create VM and Clone Code
- A virtual machine is created in AWS.
- Java code is cloned from the repository.  
![Code Retrieval](https://github.com/user-attachments/assets/c39597c1-4cc9-48cf-b5ad-9ef3b908dd57)

### 2. Install Dependencies
- Required packages and dependencies for the source code are installed.  
![Install Dependencies](https://github.com/user-attachments/assets/9396bbd2-ec0b-4f6f-af36-aa1400627920)

### 3. Build the Project
- Project is built and a `.war` file is generated.   
![Build Project](https://github.com/user-attachments/assets/127273e6-3f64-4402-bfd3-9c33bbbc785d)

### 4. Setup and Launch SonarQube
- Another VM is prepared with SonarQube and its dependencies installed.
- Code analysis is performed successfully.  
![SonarQube Setup](https://github.com/user-attachments/assets/1ae5b2f1-8487-45dc-8c71-6f482ccf26ae)  
![SonarQube Result](https://github.com/user-attachments/assets/a2efd6c6-75a0-4f3b-9896-354826d32cea)

### 5. Access Results via Web
- Analysis results are available via the web interface on port 9000.  
![Web Interface](https://github.com/user-attachments/assets/c8de1e64-660a-4e8f-90e2-765d2c60086c)

### 6. Apache Archiva
- A new VM is created, the xetusoss/archiva image is pulled from Docker Hub, and the container is started.
- The .war file is uploaded to the artifact repository.
![Result of successful upload `.war`](https://github.com/user-attachments/assets/2ecb96d1-7c35-4a6b-bfba-7e2632017bbb)

### 7. Apache Tomcat
- A new VM is created, the Tomcat image is pulled from Docker Hub, and the container is started.
![Result of successful deployment `.war`](https://github.com/user-attachments/assets/09aa3d2a-b29e-46d2-b088-7862f8a91192)

### 8. Ansible
- A new VM is created, and an Ansible playbook is written to automate downloading the `.war` file, building a Docker image with Tomcat, and pushing it to Docker Hub.
```yaml
---
- name: Push a built Docker image to Docker hub
  hosts: localhost
  connection: local
  vars_files:
    - vault.yml
  tasks:
    - name: Pull .war from Apache Archiva
      get_url:
        url: http://3.76.218.228:8080/repository/internal/com/iwayq/iwayQApp/1.0-RELEASE/iwayQApp-1.0-RELEASE.war
        dest: /dockercode/
        url_username: admin
        url_password: ***********

    - name: Login into DockerHub
      docker_login:
        username: yuriiozhho
        password: "{{ docker_hub_token }}"
        registry_url: https://index.docker.io/v1/

    - name: Pull Tomcat image
      docker_image:
        name: tomcat:latest
        source: pull

    - name: Build the new image
      docker_image:
        name: iwayq
        build:
          path: /dockercode/
          pull: no
          args:
            listen_port: 8080
        source: build

    - name: Push to Docker Hub
      docker_image:
        name: iwayq
        repository: yuriiozhho/iwayq:1.0
        push: yes
        source: local
```

![Process of performing Ansible tasks](https://github.com/user-attachments/assets/d2493117-c573-4d3c-b114-0f0e30242761)

![Result successful delivery image to Docker Hub](https://github.com/user-attachments/assets/6204b81c-e67d-48fe-8ce8-7f16eb4b32a9)

