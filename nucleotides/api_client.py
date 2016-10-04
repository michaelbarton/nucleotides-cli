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

def validate_response(app, response):
    """
    Checks the HTTP response from the API is within the expected set of values.
    Logs the error and exits if not.
    """
    import sys
    msg = "Received {} status code from '{}' with message: '{}'"\
            .format(response.status_code, response.url, response.text)
    if not response.status_code in [200, 201]:
        app['logger'].fatal(msg)
        exit(1)
    else:
        app['logger'].debug(msg)


def fetch_task(id_, app):
    url = task_url(id_, app)
    app['logger'].debug("Fetching benchmark info from '{}'".format(url))
    response = requests.get(url)
    validate_response(app, response)
    return json.loads(response.text)


def post_event(event, app):
    url = event_url(app)
    headers = {'Content-Type': 'application/json'}
    data = json.dumps(event)
    app['logger'].debug("Posting benchmark event '{}'".format(data))
    response = requests.post(url, data = data, headers = headers)
    validate_response(app, response)
