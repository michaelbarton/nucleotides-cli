import os.path, shutil

def run(task, args):
    shutil.rmtree(os.path.join("nucleotides", task))
