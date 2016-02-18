import os, tempfile
import nucleotides.log as log

def test_application_state():
    path = tempfile.mkdtemp()
    return {'api'    : os.environ["DOCKER_HOST"],
            'logger' : log.create_logger(os.path.join(path, "benchmark.log")),
            'path'   : path}

def sample_benchmark_task():
    return {
            "type": "produce",
            "benchmark": "453e406dcee4d18174d4ff623f52dcd8",
            "inputs": [
                {
                    "sha256": "11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533",
                    "url": "s3://nucleotides-testing/short-read-assembler/reads.fq.gz",
                    "type": "short_read_fastq"
                    }
                ],
            "id": 1,
            "image": {
                "name": "bioboxes/ray",
                "sha256": "digest_2",
                "task": "default",
                "type": "short_read_assembler"
                },
            "complete": False
            }
