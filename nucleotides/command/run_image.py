import funcy
import nucleotides.filesystem    as fs
import biobox.util               as docker
import biobox.container          as container
import biobox.image.availability as avail
import biobox.image.execute      as image
import nucleotides.util          as util

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
    return image.create_container(
            image_version(app),
            image_type(app).biobox_args(app),
            {"output" : fs.get_tmp_dir_path(app)},
            image_task(app))


def copy_output_files(app):
    avail.get_image(image_version(app))
    if (image_name(app) == 'bioboxes/quast'):          # Quast also does not produce
        return image_type(app).copy_output_files(app)   # a standard biobox.yaml
    else:
        paths = image_type(app).output_files()
        args  = fs.get_output_biobox_file_arguments(app)
        for (dst, path) in paths:
            src = funcy.get_in(args, path + ['value'])
            fs.copy_tmp_file_to_outputs(app, src, dst)


def execute_image(app):
    setup(app)
    biobox = create_container(app)
    id_ = biobox['Id']

    docker.client().start(id_)
    metrics = container.collect_runtime_metrics(id_)

    fs.create_runtime_metric_file(app, metrics)
    copy_output_files(app)

def run(task):
    execute_image(util.application_state(task))
