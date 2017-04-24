"""\

TaskInterface - Abstract class for nucleotides benchmarking

Defines an abstract base class with methods that must be implemented for executing
and collecting the results of each biobox type.

"""
import abc

def select_task(c):
    """
    Select appropriate subclass of the TaskInterface to use for nucleotides
    benchmarking task.
    """
    from nucleotides.task.short_read_assembler           import ShortReadAssemblerTask
    from nucleotides.task.reference_assembly_evaluation  import ReferenceAssemblyEvaluationTask
    return {
            'short_read_assembler'          : ShortReadAssemblerTask,
            'reference_assembly_evaluation' : ReferenceAssemblyEvaluationTask
            }[c]



class TaskInterface(object):
    __metaclass__ = abc.ABCMeta


###################################################################
#
# Setup methods prior to launching the container
#
###################################################################


    def before_container_hook(self, app):
        """
        Hook into process of creating a Docker container before launch. Can be used
        to perform any specific actions required before launching. This is optional
        if nothing needs to be done before launching the container.
        """
        return


    @abc.abstractmethod
    def biobox_args(self, app):
        """
        Create the argument dictionary used to populate the biobox.yaml file passed
        to the biobox Docker image.
        """
        return


###################################################################
#
# Benchmarking file and metric collection methods
#
###################################################################

    @abc.abstractmethod
    def output_file_paths(self, app):
        """
        Return a list the paths for the files generated by biobox. These are the
        files that should be collected and uploaded to nucleotides after the task
        has been completed.
        """
        return


    @abc.abstractmethod
    def metric_mapping_file(self, app):
        """
        Return the name of the metric mapping that should be used for parsing and
        validating the metrics.
        """
        return


    @abc.abstractmethod
    def collect_metrics(self, app):
        """
        Once the biobox docker image has completed, this method when called should
        return a dictionary of all metrics generated the container.
        """
        return

###################################################################
#
# Benchmarking validation methods
#
###################################################################

    @abc.abstractmethod
    def successful_event_output_files(self):
        """
        List the file types that should be expected to be produced upon successful
        completion of the biobox container execution. This is compared with the list
        of files actually produced to determine if the container successfully
        completed.
        """
        return


    def are_generated_metrics_valid(self, app, metrics):
        """
        Optionally implemented method that is used to check that the collected
        metrics are valid. If returns False, the benchmarking task state will be
        success state will be set to False and considered to have failed.
        """
        return True
