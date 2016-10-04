import logging

def create_logger(path):

    # Logging to file
    logging.basicConfig(
            level=logging.DEBUG,
            filename=path,
            format='[%(asctime)s] %(name)-12s %(levelname)-8s %(message)s',
            filemode='w')
    logger = logging.getLogger("nucleotides.client")
    return logger
