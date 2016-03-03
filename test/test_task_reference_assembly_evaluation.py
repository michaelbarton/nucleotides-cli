import os.path, docker
import nose.tools         as nose
import helper.application as app_helper
import helper.file        as file_helper

import nucleotides.task.reference_assembly_evaluation as task

def test_create_biobox_args():
    app  = app_helper.mock_reference_evaluator_state()
    args = task.create_biobox_args(app)
    nose.assert_equal("run", args[0])
    nose.assert_equal("assembler_benchmark", args[1])
    nose.assert_equal("bioboxes/quast", args[2])
    nose.assert_equal("--input-fasta={}/inputs/contig_fasta/7e9f760161.fa".format(app["path"]), args[3])
    nose.assert_equal("--input-ref={}/inputs/reference_fasta".format(app["path"]), args[4])
    nose.assert_equal("--output={}/tmp/assembly_metrics".format(app["path"]), args[5])
    nose.assert_equal("--task=default", args[6])
    nose.assert_equal("--no-rm", args[7])
