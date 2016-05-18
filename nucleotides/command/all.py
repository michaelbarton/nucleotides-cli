import nucleotides.command.fetch_data
import nucleotides.command.run_image
import nucleotides.command.post_data
import nucleotides.command.clean_up

def run(task):
    nucleotides.command.fetch_data.run(task)
    nucleotides.command.run_image.run(task)
    nucleotides.command.post_data.run(task)
    nucleotides.command.clean_up.run(task)
