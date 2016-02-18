import os, re, json, requests

def task_url(id_, app_state):
    url = "/".join([app_state['api'], "tasks", id_])
    if not re.match('(?:http|ftp|https)://', url):
        url = "http://" + url
    return url

def fetch_task(id_, app_state):
    url = task_url(id_, app_state)
    response = requests.get(url = url)
    if not response.status_code == 200:
        raise IOError("Received {} status code from '{}'".format(response.status_code, url))
    return json.loads(response.text)
