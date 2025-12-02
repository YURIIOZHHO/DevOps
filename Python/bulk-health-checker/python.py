import datetime
import requests
import csv
import re
import os

filename = "/home/ec2-user/DevOps/Python/bulk-health-checker/services.csv"

log_file = "/home/ec2-user/DevOps/Python/bulk-health-checker/log.txt" 

def read_url(filename):
    with open(filename, 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        
        fields = []
        rows = []

        fields = next(csvreader)
        for row in csvreader:
            rows.append(row)

        count_of_line =((csvreader.line_num) - 1)
        print("Total number of rows in services.csv:", count_of_line)
    
    return fields, rows, count_of_line



def create_url(rows):

    arr_url = []

    for row in rows:
        elem = ','.join(row).replace(",", "")
        arr_url.append(elem)

    return arr_url

def check_url(arr_url):

    arr_responses = []

    for url in arr_url:
        try:
        
            response = requests.get(url, timeout=5)
            total_sec = response.elapsed.total_seconds()
            status = str(response.status_code)

            some_inf = f"\nURL: {url}\n\
Status code: {response.status_code}\n\
Responce time: {total_sec}s\n"

            if re.search("^2", status):
                arr_responses.append(some_inf + "Service successfully working")
            elif re.search("^3", status):
                arr_responses.append(some_inf + "Redirection")
            elif re.search("^4", status):
                arr_responses.append(some_inf + "Client error")
            elif re.search("^5", status):
                arr_responses.append(some_inf + "Server error")
            else:
                arr_responses.append(some_inf + "Unknown status")
        

        except requests.exceptions.RequestException as e:
            arr_responses.append(f"\nERROR connecting to {url}: {e}")

    return arr_responses

def write_result_to_log_file(log_file, msgs, count_of_line):
    with open(log_file, 'a') as logfile:
        for msg in msgs:
            logfile.write(msg + "\n\n")

    
    view_log_records(count_of_line)


def view_log_records(count_of_line):
    path = "/home/ec2-user/DevOps/Python/bulk-health-checker/log.txt"
    
    with open(path, 'r') as f:
        content = f.read()
        
    records = content.strip().split("\n\n")

    last_records = records[-count_of_line:]

    print(f"\n==== LAST {count_of_line} RECORDS IN LOG ====\n")
    for rec in last_records:
        print(rec)
        print()

if __name__ == "__main__":

    fields, rows, count_of_line = read_url(filename)

    arr_url = create_url(rows)

    msgs = check_url(arr_url)

    write_result_to_log_file(log_file, msgs, count_of_line)
