import funcy
import biobox.util       as docker
import biobox.container  as container
import nucleotides.util  as util

def execute_image(app):
    image_type = util.select_task(funcy.get_in(app, ["task", "image", "type"]))
    container  = image_type.create_container(app)

    docker.client().start(container['id'])
    metrics = container.collect_metrics(container['id'])

    create_runtime_metric_file(app, metrics)
    image_type.copy_output_files(app)

def run(task):
    execute_image(util.application_state(task))
