import funcy, os
import biobox.util               as docker
import biobox.container          as container
import biobox.cgroup             as cgroup
import biobox.image.availability as avail
import biobox.image.execute      as image

import nucleotides.filesystem          as fs
import nucleotides.util                as util
import nucleotides.task.task_interface as interface

def replacement_image_type(app):
    return interface.select_task(funcy.get_in(app, ["task", "image", "type"]))()

def image_type(app):
    return util.select_task(funcy.get_in(app, ["task", "image", "type"]))

def image_name(app):
    return funcy.get_in(app, ["task", "image", "name"])

def image_version(app):
    return funcy.get_in(app, ["task", "image", "name"]) + \
           "@sha256:" + \
           funcy.get_in(app, ["task", "image", "sha256"])

def image_task(app):
    return funcy.get_in(app, ["task", "image", "task"])

def setup(app):
    biobox = image_type(app)
    if hasattr(biobox, 'before_container_hook'):
        biobox.before_container_hook(app)

def create_container(app):
    avail.get_image(image_version(app))
    dirs = {"output"   : fs.get_task_dir_path(app, 'tmp'),
            "metadata" : fs.get_task_dir_path(app, 'meta')}
    return image.create_container(
            image_version(app),
            replacement_image_type(app).biobox_args(app),
            dirs,
            image_task(app))


def copy_output_files(app):
    """
    Creates a list of source file paths and destination directory names. Copies each
    the source file to destination directory.
    """
    path = lambda x: os.path.abspath(fs.get_task_file_path(app, x))

    output_files  = {'container_log' : path('meta/log.txt')}

    if fs.biobox_yaml_exists(app):
        tmp_files    = funcy.walk_values(lambda x: path("tmp/" + x), replacement_image_type(app).output_file_paths(app))
        output_files = funcy.merge(output_files, tmp_files)
    else:
        msg = "No biobox.yaml file created, cannot find paths of any container generated files"
        app['logger'].warn(msg)

    fs.copy_container_output_files(app, output_files)


def execute_image(app, docker_timeout = 15, metric_interval = 15, metric_warmup = 2):
    setup(app)
    image  = image_version(app)

    app['logger'].info("Creating Docker container from image {}".format(image))
    biobox = create_container(app)
    id_    = biobox['Id']

    app['logger'].info("Starting Docker container {}".format(id_))
    docker.client(docker_timeout).start(id_)
    metrics = cgroup.collect_runtime_metrics(id_, metric_interval, metric_warmup)
    app['logger'].info("Docker container {} finished".format(id_))

    fs.create_runtime_metric_file(app, metrics)
    copy_output_files(app)


def run(task, args):
    app = util.application_state(task)
    interval = int(args['--polling'])
    execute_image(app, docker_timeout = interval, metric_interval = interval)
