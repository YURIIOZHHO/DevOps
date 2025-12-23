### Ansible Demo Project

#### Description task:

- Write Ansible Playbook that connects to the newly provisioned server and installs Docker and Docker Compose on it.
- It then copies a docker-compose file to the server and start the Docker containers configured inside the compose file.

playbok.yaml:
```yaml
---
- name: Demo project (install Docker and Docker Compose with starting containers)
  hosts: webserver
  become: true

  tasks:
    - name: Update DNF repository cache
      dnf:
        update_cache: yes

    - name: Install Docker
      dnf:
        name: docker
        state: present

    - name: Adding ec2-user to docker group
      user:
        name: ec2-user
        groups: docker
        append: true

    - name: Ensure Docker is started
      service:
        name: docker
        state: started
        enabled: true

    - name: Get latest Docker Compose version
      shell: |
        curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
      register: compose_version
      changed_when: false

    - name: Download Docker Compose binary
      get_url:
        url: "https://github.com/docker/compose/releases/download/{{ compose_version.stdout }}/docker-compose-linux-x86_64"
        dest: /usr/local/bin/docker-compose
        mode: '0755'

   - name: Ensure Docker Compose is executable
      file:
        path: /usr/local/bin/docker-compose
        mode: '0755'

    - name: Verify Docker Compose installation
      command: docker-compose --version
      register: compose_check
      changed_when: false

    - name: Crete dir for Docker Compose file
      file:
        path: /home/ec2-user/docker
        state: directory
        mode: '0755'
        owner: ec2-user
        group: ec2-user

    - name: Copy docker compose file
      template:
        src: /docker/docker-compose.yaml
        dest: /home/ec2-user/docker/
        owner: ec2-user
        group: ec2-user
        mode: '0644'

    - name: Start Docker Compose
      command: docker-compose up -d
      args:
        chdir: /home/ec2-user/docker
```

Result on Ansible master: 

!["Task performed successfully"](https://github.com/user-attachments/assets/015d98b1-6bd3-4595-8be0-96d8bc2752e5)

Result on Ansible slave: 

!["Result of the performed task"](https://github.com/user-attachments/assets/dc4231d9-bffe-46c5-922b-fda21b68010c)


