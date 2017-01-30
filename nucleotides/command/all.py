import nucleotides.command.fetch_data
import nucleotides.command.run_image
import nucleotides.command.post_data
import nucleotides.command.clean_up

def run(task, args):
    nucleotides.command.fetch_data.run(task, args)
    nucleotides.command.run_image.run(task, args)
    nucleotides.command.post_data.run(task, args)
    nucleotides.command.clean_up.run(task, args)
