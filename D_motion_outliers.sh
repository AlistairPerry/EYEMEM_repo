source preproc2_config.sh

# PBS Log Info
CurrentPreproc="mo_out"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error log
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${CurrentLog}

# Loop over participants, sessions (if they exist) & runs/conditions/tasks/etc
for SUB in ${SubjectID} ; do
	for TASK in ${TaskID}; do
		
		if [ $TASK == "rest" ]; then RunID="NoRun"; else source preproc2_config.sh; fi
				
		for RUN in ${RunID}; do
			
			# Name of functional image to be used.
			if [ ${TASK} == "rest" ]; then
				FuncImage="${SUB}_task-${TASK}_bold"
			elif [ ${TASK} == "eyemem" ]; then
				FuncImage="${SUB}_task-${TASK}_run-${RUN}_bold"
			fi
			
			# Path to the original functional image folder.
			OriginalPath="${DataPath}/${SUB}/func"
			
			# Path to the pipeline specific folder.
			if [ ${TASK} == "rest" ]; then
				FuncPath="${WorkingDirectory}/data/mri/resting_state/preproc/${SUB}"
			elif [ ${TASK} == "eyemem" ]; then
				FuncPath="${WorkingDirectory}/data/mri/task/preproc/${SUB}/run-${RUN}"
			fi
				
			if [ ! -f ${OriginalPath}/${FuncImage}.nii.gz ]; then
				continue
			elif [ -f ${FuncPath}/motionout/${SUB}_motionout.txt ]; then
				continue
			fi
			
			if [ ${TASK} == "rest" ]; then
				DeleteVolumes=${DeleteVolumes_rest}
			elif [ ${TASK} == "eyemem" ]; then
				DeleteVolumes=${DeleteVolumes_rest}
			else
				echo "Task not found"; continue
			fi
			
			# Create output path for motion outlier detection
			if [ ! -d ${FuncPath}/motionout ]; then mkdir -p ${FuncPath}/motionout; fi

			# Gridwise
			echo "#PBS -N ${CurrentPreproc}_${SUB}_${TASK}_${RUN}" 						>> job # Job name 
			echo "#PBS -l walltime=12:00:00" 									>> job # Time until job is killed 
			echo "#PBS -l mem=8gb" 												>> job # Books 4gb RAM for the job 
			echo "#PBS -m n" 													>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#PBS -o ${CurrentLog}" 										>> job # Write (output) log to group log folder 
			echo "#PBS -e ${CurrentLog}" 										>> job # Write (error) log to group log folder 

			#echo ". /etc/fsl/5.0/fsl.sh"										>> job # Set fsl environment 	
			echo "FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11"  >> job
			echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
			echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
			echo "export FSLDIR PATH"                               >> job
			
			echo "cd ${FuncPath}"           												>> job

			# Run motion outlier detection
			echo "fsl_motion_outliers -i ${OriginalPath}/${FuncImage} -o ${FuncPath}/motionout/${SUB}_motionout.txt -s ${FuncPath}/motionout/${SUB}_${MoutMetric}.txt -p ${FuncPath}/motionout/${SUB}_${MoutMetric}_plot.png --${MoutMetric} --dummy=${DeleteVolumes} -v >> ${FuncPath}/motionout/report.txt" >> job
			
			# Error log
			echo "if [ ! -f ${FuncPath}/motionout/${SUB}_motionout.txt ];"  		>> job
			echo "then echo 'Error in ${FuncImage}' >> ${Error_Log}; fi"				>> job
			
			qsub job
			rm job
			
		done
	done
done