import os, shutil, json

import ruamel.yaml           as yaml
import boltons.fileutils     as fu
import helper.file           as file_helper
import nucleotides.log       as log

def mock_app():
    path = file_helper.test_dir()
    app = {'api'       : os.environ["NUCLEOTIDES_API"],
           'logger'    : log.create_logger(os.path.join(path, "benchmark.log")),
           'path'      : path,
           's3-upload' : "s3://"
           }
    return app


def copy_to_file(src_file, dst_file, app):
    file_ = os.path.join(app['path'], dst_file)
    dir_  = os.path.dirname(file_)
    fu.mkdir_p(dir_)
    shutil.copy(src_file, file_)


def setup_app_state(file_group, file_set = None):
    with open('test/data/files.yml') as f:
        config = yaml.load(f.read())

    app = mock_app()

    if file_set:
        for f in config[file_group][file_set]:
            copy_to_file(f['src'], f['dst'], app)
        with open(app['path'] + '/metadata.json', 'r') as f:
            app["task"] = json.loads(f.read())
    return app


def rewrite_app_task(app):
    with open(app['path'] + '/metadata.json', 'w') as f:
        f.write(json.dumps(app["task"]))
