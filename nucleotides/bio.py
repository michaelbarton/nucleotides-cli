import tempfile, os, os.path
import pyfaidx  as fa

import nucleotides.filesystem as fs


def filter_contig_file(src_path, min_length):
    """
    Filters a FASTA file containing contigs. Removes all contigs whose length is
    less than the supplied min length parameter.
    """
    tmp = tempfile.mktemp(prefix = 'nucleotides_filtered_contigs')
    with open(tmp, 'w') as f:
        for contig in fa.Fasta(src_path):
            if len(contig) > min_length:
                f.write('>' + str(contig.long_name) + "\n")
                for line in contig:
                    f.write(str(line) + "\n")
    digest = fs.sha_digest(tmp)
    dst = os.path.join(os.path.dirname(src_path), digest) + '.fa'
    os.remove(src_path)
    os.remove(src_path + '.fai')
    os.rename(tmp, dst)
    return dst
