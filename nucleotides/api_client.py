import os, re, json, requests

def task_url(host, id_):
    url = "/".join([host, "tasks", id_])
    if not re.match('(?:http|ftp|https)://', url):
        url = "http://" + url
    return url

def fetch_task(host, id_):
    url = task_url(host, id_)
    response = requests.get(url = url)
    if not response.status_code == 200:
        raise IOError("Received {} status code from '{}'".format(response.status_code, url))
    return json.loads(response.text)
