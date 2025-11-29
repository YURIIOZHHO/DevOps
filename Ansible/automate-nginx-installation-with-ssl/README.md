## Automate Nginx Web Server Installation

### Implementation:

#### 1. Create a playbook to install Nginx on remote server using Ansible’s yum modules.  
#### 2. Configure the server to serve a default webpage or a custom HTML file.  
#### 3. Set up SSL for secure connections (using Let’s Encrypt, for example).  
#### 4. Test the server’s functionality by sending HTTP requests to verify that the website is being served correctly.  
#### 5. Use Ansible templates to create custom configuration files for each server.  

### Obtaining a Domain

#### The first step is to get domain. I used the https://www.duckdns.org/ (Duck DNS), which provides free dynamic DNS.   
  
#### As a result, I obtainced the following domain: 
```
nginx-domain-for-ansible-task
```

!["Successfully generated DuckDNS domain"](https://github.com/user-attachments/assets/d89e0983-f9dc-4afa-b882-0945309258bd)

### Initial NGINX configuration

#### Before configuring SSL, I deployed NGINX over plain HTTP and verified that it works:
```
playbook.yaml:
```
```yaml
---
- name: Automate Nginx on Amazon Linux 2023(EC2)
  hosts: webserver
  become: yes

 tasks:
    - name: Update all packages
      ansible.builtin.dnf:
        name: "*"
        state: latest

    - name: Install Nginx 
      ansible.builtin.dnf: 
        name: nginx
        state: latest

    - name: Ensure Nginx is running and enabled 
      service:
        name: nginx
        state: started 
        enabled: true
```
```
ansible.cfg:
```
```yaml
[defaults]
inventory = inventory.ini
host_key_checking = False
retry_files_enabled = False
forks = 20

[ssh_connection]
pipelining = True
```
```
inventory.ini:
```
```yaml
[webserver]
web ansible_host=172.31.19.90 ansible_user=ec2-user ansible_ssh_private_key_file=vm-key.pem

[webserver:vars]
port=8080
```

#### Nginx successfully responding on HTTP:
!["Nginx successfully responding on HTTP"](https://github.com/user-attachments/assets/90905afc-3960-4a37-bfa5-0f241f0022c0)

#### Full playbook with SSL (Let's encrypt)
#### After verifying that HTTP works, I proceeded to configure HTTPS using Certbot.
### All variable values such as ```domain``` and ```duckdns_account``` are stored in ```vars.yaml``` and ```vault.yaml```

Final ```playbook.yaml```
```yaml
---
- name: Automate Nginx + HTTPS (Let’s Encrypt) on Amazon Linux 2023(EC2)
  hosts: webserver
  become: yes
  vars_files:
    - vars.yaml
    - vault.yaml

  tasks:
    - name: Update all packages
      ansible.builtin.dnf:
        name: "*"
        state: latest

    - name: Install Nginx and Certbot
      dnf:
        name:
          - nginx
          - certbot
        state: latest

    - name: Ensure Nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: true

    - name: Create webroot directory for the domain
      file:
        path: "/usr/share/nginx/html/{{ domain }}"
        state: directory
        owner: nginx
        group: nginx
        mode: "0755"

    - name: Deploy test index.html
      copy:
        src: files/index.html
        dest: "/usr/share/nginx/html/{{ domain }}/index.html"
        owner: nginx
        group: nginx
        mode: "0644"

    - name: Obtain Let's Encrypt certificate via HTTP-01
      command: >
        certbot certonly --non-interactive --agree-tos
        --email {{ duckdns_account }}
        --webroot -w /usr/share/nginx/html
        -d {{ domain }}
      args:
        creates: "/etc/letsencrypt/live/{{ domain }}/fullchain.pem"

    - name: Configure Nginx for HTTPS
      template:
        src: templates/nginx.conf.j2
        dest: "/etc/nginx/conf.d/{{ domain }}.conf"
        owner: root
        group: root
        mode: "0644"
      notify: reload nginx

    - name: Reload Nginx to apply new config
      service:
        name: nginx
        state: reloaded


    - name: Test server functionality (HTTPS request)
      uri:
        url: "https://{{ domain }}"
        method: GET
        validate_certs: yes
        status_code: 200
        return_content: yes
      delegate_to: localhost
      register: http_check

    - name: Display test result
      ansible.builtin.debug:
        msg: "Successfully received response (Status: {{ http_check.status }}). First 100 chars of content: {{ http_check.content[:100] }}"

  handlers:
    - name: reload nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded
```

```vars.yaml```
```yaml
domain: "nginx-domain-for-ansible-task.duckdns.org"
```

#### HTTPS result

#### Ansible playbook execution and successfully result:
!["Ansible playbook execution and successfully result"](https://github.com/user-attachments/assets/00dfedc7-1bdb-4dd3-835e-3cdc761e7814)

#### HTTPS connection results:
![HTTPS connection results](https://github.com/user-attachments/assets/e4eaa3f2-ab81-4634-988c-61d79e83793b)

### Conclusion:  
#### This automation allows deploying a fully configured and secure Nginx web server on Amazon Linux 2023 using a single Ansible playbook. The setup includes package installation, webroot preparation, SSL generation, templated configuration, and automated testing.
