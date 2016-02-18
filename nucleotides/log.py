import logging

def create_logger(path):
    logger = logging.getLogger("nucleotides")
    fh = logging.FileHandler(path)
    fh.setLevel(level = logging.INFO)
    logger.addHandler(fh)
    return logger
