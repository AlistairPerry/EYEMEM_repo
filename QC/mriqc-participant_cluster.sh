# This script creates participant-level mriqc reports for a BIDS structured dataset.

# Configuration

source preproc2_config.sh

container_path="${SharedFilesPath_toolboxes}/mriqc/freesurfer-mriqc-0.11.0.simg" # path on cluster containing the mriqc container

IQM_outpath="${WorkingDirectory}/BIDS/mriqc" #output folder of mriqc

job_logs_path="${LogPath}/mriqc" # Path where error and out logs of cluster jobs are saved

work_path="${IQM_outpath}/work" # Path of work directory containing intermediary files created when running mriqc

cpus='4' # Specify number of cpus to speed up processing

mem_T1w='10' # memory allocation for T1w pipeline
mem_bold='8' # memory allocation for bold pipeline

# make output folder
if [ ! -d ${IQM_outpath} ]
then
	mkdir -p ${IQM_outpath}
	chmod 770 ${IQM_outpath}
fi

# make work folder
if [ ! -d ${work_path} ]
then
	mkdir -p ${work_path}
	chmod 770 ${work_path}
fi

# make job log folder
if [ ! -d ${job_logs_path} ]
then
	mkdir -p ${job_logs_path}
	chmod 770 ${job_logs_path}
fi

#T1w
for SUB in $SubjectID
do
		
	if [ ! -f ${DataPath}/${SUB}/anat/${SUB}_T1w.nii.gz ]
	then
		echo "No T1w image for ${SUB}"
		continue
		
	elif [ -f ${IQM_outpath}/reports/${SUB}_T1w.html ]
	then	
		echo "T1w report for ${SUB} already produced"
		continue
	fi
		
		echo "#PBS -N mriqc_T1w_${SUB}" 											>> job # Job name 
		echo "#PBS -l walltime=12:00:00" 									>> job # Time until job is killed 
		echo "#PBS -l mem=${mem_T1w}gb" 											>> job # Books 8gb RAM for the job 
		echo "#PBS -m n" 													>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#PBS -o ${job_logs_path}"					 	>> job # Write (output) log to group log folder 
		echo "#PBS -e ${job_logs_path}" 						>> job # Write (error) log to group log folder 
		echo "#PBS -l nodes=1:ppn=${cpus}" 						>> job # request multiple cpus
		
		# bind LNDG path to singularity container
		echo "export SINGULARITY_BINDPATH=${WorkingDirectory}" >> job
		
		echo "singularity exec ${container_path} mriqc ${DataPath} ${IQM_outpath} participant --participant-label ${SUB} -m T1w -w ${work_path} --verbose-reports --n_cpus ${cpus} --mem_gb ${mem_T1w} --no-sub" >> job
	
		qsub job
		rm job
done

for SUB in $SubjectID
do
		
		echo "#PBS -N mriqc_bold_${SUB}" 											>> job # Job name 
		echo "#PBS -l walltime=12:00:00" 									>> job # Time until job is killed 
		echo "#PBS -l mem=${mem_bold}gb" 											>> job # Books 8gb RAM for the job 
		echo "#PBS -m n" 													>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#PBS -o ${job_logs_path}"					 	>> job # Write (output) log to group log folder 
		echo "#PBS -e ${job_logs_path}" 						>> job # Write (error) log to group log folder 
		echo "#PBS -l nodes=1:ppn=${cpus}" 						>> job # request multiple cpus
		
		# bind LNDG path to singularity container
		echo "export SINGULARITY_BINDPATH=${WorkingDirectory}" >> job
		
		echo "singularity exec ${container_path} mriqc ${DataPath} ${IQM_outpath} participant --participant-label ${SUB} -m bold -w ${work_path} --verbose-reports --n_cpus ${cpus} --mem_gb ${mem_bold} --no-sub" >> job
	
		qsub job
		rm job
done