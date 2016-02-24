import os
import helper.file           as file_helper
import biobox_cli.util.misc  as bbx_util
import nucleotides.log       as log

def test_application_state():
    path = file_helper.test_dir()
    return {'api'    : os.environ["NUCLEOTIDES_API"],
            'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
            'path'   : path}

def test_existing_application_state():
    import json, shutil

    app = test_application_state()
    app["task"] = sample_benchmark_task()
    with open(app['path'] + '/metadata.json', 'w') as f:
        f.write(json.dumps(app["task"]))
    bbx_util.mkdir_p(app['path'] + '/inputs/short_read_fastq/')
    shutil.copy('tmp/data/dummy.reads.fq.gz', app['path'] + '/inputs/short_read_fastq/')
    return app

def sample_benchmark_task():
    return {
            "type": "produce",
            "benchmark": "453e406dcee4d18174d4ff623f52dcd8",
            "inputs": [
                {
                    "sha256": "24b5b01b08482053d7d13acd514e359fb0b726f1e8ae36aa194b6ddc07335298",
                    "url": "s3://nucleotides-testing/short-read-assembler/dummy.reads.fq.gz",
                    "type": "short_read_fastq"
                    }
                ],
            "id": 1,
            "image": {
                "name": "bioboxes/velvet",
                "sha256": "digest_2",
                "task": "default",
                "type": "short_read_assembler"
                },
            "complete": False
            }
