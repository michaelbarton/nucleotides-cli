import abc

def select_task(c):
    from nucleotides.task.short_read_assembler           import ShortReadAssemblerTask
    from nucleotides.task.reference_assembly_evaluation  import ReferenceAssemblyEvaluationTask
    return {
            'short_read_assembler'          : ShortReadAssemblerTask,
            'reference_assembly_evaluation' : ReferenceAssemblyEvaluationTask
            }[c]


class TaskInterface(object):
    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def biobox_args(self, app):
        """
        Create the biobox dictionary used to populate the biobox.yaml file given
        to the biobox Docker image.
        """
        return


    @abc.abstractmethod
    def output_file_paths(self, app):
        """
        List the paths of the generated biobox files. These are the files that
        should be collected and uploaded to nucleotides after the task has been
        completed.
        """
        return