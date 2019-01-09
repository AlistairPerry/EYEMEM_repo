source /home/mpib/LNDG/EyeMem/study_information/A_scripts/Z_archive/fmriprep/preproc2_config.sh

# PBS Log Info
CurrentPreproc="fmriprep"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

FSlicense="/home/mpib/LNDG/EyeMem/study_information/C_toolboxes/license.txt"

mem_mb="$(echo "${mem}*1000" | bc)" # memory allocation in mb

for SUB in ${SubjectID} ; do
	
	#output path
	fmriprepOut="${WorkingDirectory}/data/mri/fmriprep/${SUB}/out"
	if [ ! -d ${fmriprepOut} ]; then mkdir -p ${fmriprepOut}; chmod 770 ${fmriprepOut}; fi
		
	#work path
	fmriprepWork="${WorkingDirectory}/data/mri/fmriprep/${SUB}/work"
	if [ ! -d ${fmriprepWork} ]; then mkdir -p ${fmriprepWork}; chmod 770 ${fmriprepWork}; fi

	echo "#PBS -N ${CurrentPreproc}_${SUB}" 						>> job # Job name 
	echo "#PBS -l walltime=24:00:00" 									>> job # Time until job is killed 
	echo "#PBS -l mem=${mem}gb" 												>> job # Books 4gb RAM for the job 
	echo "#PBS -m n" 													>> job # Email notification on abort/end, use 'n' for no notification 
	echo "#PBS -o ${CurrentLog}" 										>> job # Write (output) log to group log folder 
	echo "#PBS -e ${CurrentLog}" 										>> job # Write (error) log to group log folder
	echo "#PBS -l nodes=1:ppn=${cpus}" 						>> job # request multiple cpus
	
	# bind LNDG path to singularity container
	echo "export SINGULARITY_BINDPATH=${BaseDirectory}" >> job
	
	echo "singularity exec ${ContainerPath}/fmriprep-1.1.8.simg fmriprep ${DataPath} ${fmriprepOut} participant -w ${fmriprepWork} -t ${TaskID} --participant-label ${SUB} --fs-license-file ${FSlicense} --output-space T1w -n-cpus ${cpus} --mem-mb ${mem_mb} --verbose --write-graph --notrack" >> job
	
	qsub job
	rm job

done