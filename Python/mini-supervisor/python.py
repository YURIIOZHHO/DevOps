import paramiko
import os
import time
import datetime
import pytz
import requests

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

pkey_path = os.path.expanduser('/home/ec2-user/python/vm-key.pem')

def send_message_to_tgbot(msg):
    token = "8219635869:AAFwc8ZtW2IFiB0uciaqadXRyanE19_Yv-k"
    chat_id = "1142898773"
    url = f"https://api.telegram.org/bot{token}/sendMessage"

    data = {
        "chat_id": chat_id,
        "text": msg
    }

    requests.post(url, json=data)

def check_status_of_service():

    kyiv_tz = pytz.timezone('Europe/Kyiv')
    kyiv_time = datetime.datetime.now(kyiv_tz)
    status = ""
    exec_restart = ""
    err = 0

    stdin, stdout, stderr = ssh.exec_command("sudo systemctl is-active nginx")
    output = stdout.read().decode().strip()
    error = stderr.read().decode().strip()

    if output == "active":
        print("Nginx is active\n")
        
        status = "Active"
        exec_restart = "No"

        return kyiv_time, status, exec_restart, err
    
    elif output == "inactive":
        print("Nginx is inactive\n")

        print("Testing nginx configuration...\n")
        stdin_conf, stdout_conf, stderr_conf = ssh.exec_command("sudo nginx -t")
        result_conf = stderr_conf.read().decode().strip()

        if result_conf == "sudo: nginx: command not found":
            print(result_conf)
            status = "Inactive | nginx is not installed"
            exec_restart = "No"
            err = 1
            return kyiv_time, status, exec_restart, err

        ssh.exec_command("sudo systemctl restart nginx")
        print("Attempting to start Nginx...\n")
        time.sleep(2)
 
        _stdin, _stdout, _stderr = ssh.exec_command("sudo systemctl is-active nginx")
 
        _output = _stdout.read().decode().strip()
        _error = _stderr.read().decode().strip()
 
        if _output == "active":
            print("Nginx is active \n")
           
            status = "Active | Service was inactive"
            exec_restart = "Yes"
            err = 1

            return kyiv_time, status, exec_restart, err
        else:
            print("Service Nginx is not started")

            status = "Inactive"
            exec_restart = "Yes"
            err = 1

            return kyiv_time, status, exec_restart, err
 
        if _error:
            print("Error:")
            print(_error)

            status = "Error: " + _error 
            exec_restart = "Yes"
            err = 1

            return kyiv_time, status, exec_restart, err
 
    if error:
        print("Error:")
        print(error)
        
        status = "Error: " + _error
        exec_restart = "Yes"
        err = 1

        return kyiv_time, status, exec_restart, err

try:
    ssh.connect(
        hostname="172.31.29.192", 
        username="ec2-user", 
        key_filename=pkey_path
    )

    print("\nConnection successful!\n")
    
    date, status, exec_restart, err = check_status_of_service()

    msg = f"""\n
Time of checking: {date.strftime('%Y-%m-%d %H:%M:%S')}
Status of process: {status}
Service was restarted? Yes/No: {exec_restart}\n"""

    with open('log.txt', 'a') as file:
        file.write(msg)

    if err == 1:
        send_message_to_tgbot(msg)

except paramiko.ssh_exception.AuthenticationException as e:
    print(f"Authentication failed: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    ssh.close()
