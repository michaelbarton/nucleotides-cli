import funcy
import nucleotides.filesystem    as fs
import biobox.util               as docker
import biobox.container          as container
import biobox.image.availability as avail
import biobox.image.execute      as image
import nucleotides.util          as util

def image_type(app):
    return util.select_task(funcy.get_in(app, ["task", "image", "type"]))

def image_version(app):
    return funcy.get_in(app, ["task", "image", "name"]) + \
           "@sha256:" + \
           funcy.get_in(app, ["task", "image", "sha256"])

def image_task(app):
    return funcy.get_in(app, ["task", "image", "task"])

def create_container(app):
    avail.get_image(image_version(app))
    return image.create_container(
            image_version(app),
            image_type(app).biobox_args(app),
            fs.get_tmp_dir_path(app),
            image_task(app))

def execute_image(app):
    biobox = create_container(app)
    id_ = biobox['Id']

    docker.client().start(id_)
    metrics = container.collect_runtime_metrics(id_)

    fs.create_runtime_metric_file(app, metrics)
    image_type(app).copy_output_files(app)

def run(task):
    execute_image(util.application_state(task))
