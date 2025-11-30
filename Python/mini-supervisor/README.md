## Task: Python script for service monitoring and automatic restart (mini-Supervisor)

## Goal 
### Create a Python utility that:
#### Checks whether a specific Linux process is running (nginx).
##### 1. If the process is not running, restarts it.
##### 2. Keeps a log file with history:
  ##### - check time
  ##### - process status
  ##### - whether a restart was performed  
##### 3. Sends a message to Slack/Telegram Webhook when the service goes down.


##### During the process of completing the task, I created python.py, which contains all the logic.
```python.py```
```python
  1 import paramiko
  2 import os
  3 import time
  4 import datetime
  5 import pytz
  6 import requests
  7
  8 ssh = paramiko.SSHClient()
  9 ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
 10
 11 pkey_path = os.path.expanduser('/home/ec2-user/python/vm-key.pem')
 12
 13 def send_message_to_tgbot(msg):
 14     token = "8219635869:AAFwc8ZtW2IFiB0uciaqadXRyanE19_Yv-k"
 15     chat_id = "1142898773"
 16     url = f"https://api.telegram.org/bot{token}/sendMessage"
 17
 18     data = {
 19         "chat_id": chat_id,
 20         "text": msg
 21     }
 22
 23     requests.post(url, json=data)
 24
 25 def check_status_of_service():
 26
 27     kyiv_tz = pytz.timezone('Europe/Kyiv')
 28     kyiv_time = datetime.datetime.now(kyiv_tz)
 29     status = ""
 30     exec_restart = ""
 31     err = 0
 32
 33     stdin, stdout, stderr = ssh.exec_command("sudo systemctl is-active nginx")
 34     output = stdout.read().decode().strip()
 35     error = stderr.read().decode().strip()
 36
 37     if output == "active":
 38         print("Nginx is active\n")
 39
 40         status = "Active"
 41         exec_restart = "No"
 42
 43         return kyiv_time, status, exec_restart, err
 44
 45     elif output == "inactive":
 46         print("Nginx is inactive\n")
 47
 48         print("Testing nginx configuration...\n")
 49         stdin_conf, stdout_conf, stderr_conf = ssh.exec_command("sudo nginx -t")
 50         result_conf = stderr_conf.read().decode().strip()
 51
 52         if result_conf == "sudo: nginx: command not found":
 53             print(result_conf)
 54             status = "Inactive | nginx is not installed"
 55             exec_restart = "No"
 56             err = 1
 57             return kyiv_time, status, exec_restart, err
 58
 59         ssh.exec_command("sudo systemctl restart nginx")
 60         print("Attempting to start Nginx...\n")
 61         time.sleep(2)
 62
 63         _stdin, _stdout, _stderr = ssh.exec_command("sudo systemctl is-active nginx")
 64
 65         _output = _stdout.read().decode().strip()
 66         _error = _stderr.read().decode().strip()
 67
 68         if _output == "active":
 69             print("Nginx is active \n")
 70
 71             status = "Active | Service was inactive"
 72             exec_restart = "Yes"
 73             err = 1
 74
 75             return kyiv_time, status, exec_restart, err
 76         else:
 77             print("Service Nginx is not started")
 78
 79             status = "Inactive"
 80             exec_restart = "Yes"
 81             err = 1
 82
 83             return kyiv_time, status, exec_restart, err
 84
 85         if _error:
 86             print("Error:")
 87             print(_error)
 88
 89             status = "Error: " + _error
 90             exec_restart = "Yes"
 91             err = 1
 92
 93             return kyiv_time, status, exec_restart, err
 94
 95     if error:
 96         print("Error:")
 97         print(error)
 98
 99         status = "Error: " + _error
100         exec_restart = "Yes"
101         err = 1
102
103         return kyiv_time, status, exec_restart, err
104
105 try:
106     ssh.connect(
107         hostname="172.31.29.192",
108         username="ec2-user",
109         key_filename=pkey_path
110     )
111
112     print("\nConnection successful!\n")
113
114     date, status, exec_restart, err = check_status_of_service()
115
116     msg = f"""\n
117 Time of checking: {date.strftime('%Y-%m-%d %H:%M:%S')}
118 Status of process: {status}
119 Service was restarted? Yes/No: {exec_restart}\n"""
120
121     with open('log.txt', 'a') as file:
122         file.write(msg)
123
124     if err == 1:
125         send_message_to_tgbot(msg)
126
127 except paramiko.ssh_exception.AuthenticationException as e:
128     print(f"Authentication failed: {e}")
129 except Exception as e:
130     print(f"An error occurred: {e}")
131 finally:
132     ssh.close()
```

### Depending on the status of the service, the code may respond differently and handle different errors. 

#### First test. On the remote server, Nginx is not installed.

!["nginx is not installed"](https://github.com/user-attachments/assets/f4ce6839-a5ac-4495-a18e-bbe82690f692)

#### Therefore, the script should correctly detect this state. Result:
 
!["result successfuly handle error"](https://github.com/user-attachments/assets/01546d82-ce73-4671-9e0b-817fe9ab461f)

#### The message was written to ```log.txt```:
!["record in the log.txt"](https://github.com/user-attachments/assets/a90b8293-4c65-4dc0-823a-2ea7702d37c5)

####Since this situation is critical, the script also sent a notification to the Telegram channel:

!["message in tg"](https://github.com/user-attachments/assets/0920ae5e-dba1-43af-abf8-e3c495c93673)

#### Second test. On the remote server, Nginx is installed and running successfully.

!["nginx is installed and started"](https://github.com/user-attachments/assets/5f551b62-071a-482f-8898-a4deb6b76c60)

#### Obtained result:

!["obtained result"](https://github.com/user-attachments/assets/bd854d43-802d-4650-b315-fefab46c223b)

#### Log entry

!["record on log.txt"](https://github.com/user-attachments/assets/f214b184-0ea4-4bd6-99e9-73fc40c019cb)

#### Because this state is normal, no Telegram notification was sent

#### The third test checks how the script behaves when the service is stopped and must be restarted.
#### Service status before running the script:

!["status of the service"](https://github.com/user-attachments/assets/c4b8e805-b1ee-4647-9e04-5195849daa70)

#### Script output:

!["Result work of the script"](https://github.com/user-attachments/assets/eeb50b01-39be-41aa-86a4-2033273e320f)

#### Nginx has been restarted and is now running:

!["nginx is started and working"](https://github.com/user-attachments/assets/8d053cef-2883-4a9b-b9ef-931f74f39931)

### Log entry:

!["record in log.txt"](https://github.com/user-attachments/assets/99e4a02d-050a-4c77-ab95-741931135cc3)


#### Since restarting the service is a critical event, a notification was sent to Telegram.

!["message in tg"](https://github.com/user-attachments/assets/8872a629-055f-495f-bbe8-41780befdb3f)


### Conclusion:
#### This project implements a lightweight Python-based monitoring solution that acts as a simplified version of Supervisor. The script connects to a remote server over SSH, checks the state of the Nginx service, attempts to restart it when necessary, and logs every action with a timestamp. Critical events—such as service downtime or failed restarts—are additionally reported via Telegram notifications.

#### Example log entries:

```
Time of checking: 2025-11-30 18:34:00
Status of process: Active | Service was inactive
Service was restarted? Yes/No: Yes


Time of checking: 2025-11-30 18:35:09
Status of process: Active | Service was inactive
Service was restarted? Yes/No: Yes


Time of checking: 2025-11-30 18:36:12
Status of process: Inactive | nginx is not installed
Service was restarted? Yes/No: No


Time of checking: 2025-11-30 23:16:13
Status of process: Inactive | nginx is not installed
Service was restarted? Yes/No: No


Time of checking: 2025-11-30 23:35:21
Status of process: Active
Service was restarted? Yes/No: No


Time of checking: 2025-11-30 23:55:12
Status of process: Active | Service was inactive
Service was restarted? Yes/No: Yes
```

#### List libraries and dependencies:

```
bcrypt==5.0.0
certifi==2025.11.12
cffi==2.0.0
charset-normalizer==3.4.4
cryptography==46.0.3
idna==3.11
invoke==2.2.1
paramiko==4.0.0
pycparser==2.23
PyNaCl==1.6.1
pytz==2025.2
requests==2.32.5
typing_extensions==4.15.0
urllib3==2.5.0
```


