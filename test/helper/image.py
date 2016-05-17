import biobox.util, os

def clean_up_container(id_):
    if not "CIRCLECI" in os.environ:
        biobox.util.client().remove_container(id_)

