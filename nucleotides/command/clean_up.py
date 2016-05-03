import os.path, shutil

def run(task):
    shutil.rmtree(os.path.join("nucleotides", task))
