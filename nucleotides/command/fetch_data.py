import os.path

import biobox_cli.util.misc    as bbx_util
import nucleotides.util        as util
import nucleotides.api_client  as api
import nucleotides.s3          as s3

def create_input_files(app):
    for f in app['task']['inputs']:
        dst = os.path.join(app['path'], 'inputs', f['type'], os.path.basename(f['url']))
        bbx_util.mkdir_p(os.path.dirname(dst))
        s3.fetch_file(f['url'], dst)

def run(task):
    create_input_files(util.application_state(task))
