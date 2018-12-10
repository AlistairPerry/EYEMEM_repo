# This script generates mriqc group reports. Only run after all participant-level report jobs are finished! Can be run locally or in an interactive shell since it doesn't require a lot of resources and is very fast. By Alex.

source preproc2_config.sh

container_path="${SharedFilesPath_toolboxes}/mriqc/freesurfer-mriqc-0.11.0.simg" # path on cluster containing the mriqc container
IQM_outpath="${WorkingDirectory}/BIDS/mriqc"
work_path="${IQM_outpath}/work"  # Path of work directory containing intermediary files created when running mriqc

#group reports

export SINGULARITY_BINDPATH=${WorkingDirectory}

singularity exec ${container_path} mriqc ${DataPath} ${IQM_outpath} group -m T1w --no-sub
  
singularity exec ${container_path} mriqc ${DataPath} ${IQM_outpath} group -m bold --no-sub

#remove intermediary files (optional!)

#rm -r ${work_path}