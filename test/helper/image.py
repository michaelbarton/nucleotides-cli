import biobox.util, os
import nucleotides.command.run_image as run

def clean_up_container(id_):
    if not "CIRCLECI" in os.environ:
        biobox.util.client().remove_container(id_)

def execute_image(app):
    # Have to set the docker timeout to a very small value otherwise the docker
    # client will tend to hang for a long time waiting for the client stats to be
    # returned.
    #
    # Adding a warmup time slightly longer than the crash-test-biobox takes to
    # complete also ensures the stats collection should return relatively quickly.
    run.execute_image(app, docker_timeout = 1, metric_warmup = 2, metric_interval = 1)
