import os.path
import nose.tools         as nose
import helper.db          as db_helper
import helper.application as app_helper
import helper.file        as file_helper

import nucleotides.util               as util
import nucleotides.command.fetch_data as fetch

def test_fetch_input_files():
    db_helper.reset_database()
    app = app_helper.mock_short_read_assembler_state()
    fetch.create_input_files(app)
    file_helper.assert_is_file(app["path"] + "/inputs/short_read_fastq/dummy.reads.fq.gz")
