import os
import json
import requests as req

def fetch_task(id_):
    url = "/".join(["http:/", os.environ["NUCLEOTIDES_API"], "tasks", id_])
    response = req.get(url=url).text
    return json.loads(response)
