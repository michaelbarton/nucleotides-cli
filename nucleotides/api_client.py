import os, re, json, requests

def api_host(url):
    if not re.match('(?:http|ftp|https)://', url):
        url = "http://" + url
    return url

def task_url(id_, app):
    url = "/".join([app['api'], "tasks", id_])
    return api_host(url)

def event_url(app):
    url = "/".join([app['api'], "events"])
    return api_host(url)

def fetch_task(id_, app):
    url = task_url(id_, app)
    response = requests.get(url)
    if not response.status_code == 200:
        raise IOError("Received {} status code from '{}'".format(response.status_code, url))
    return json.loads(response.text)

def post_event(event, app):
    url = event_url(app)
    headers = {'Content-Type': 'application/json'}
    response = requests.post(url, data = json.dumps(event), headers = headers)
    if not response.status_code == 201:
        raise IOError("Received {} status code from '{}'".format(response.status_code, url))
