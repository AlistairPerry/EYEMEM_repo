#!/bin/bash

## ICA: Independente Component Analysis

## This will perform Independent Component Analysis. The output is a series of links which will be used to decide which components are artefacts. Components which contain unwanted artifacts will later be 'rejected' and one should keep a list of these the text file generated by the makereject function on matlab. We will also create a background image which is based off of an MNI image. This will fascilitate visual inspection of the ICAs. 

source preproc2_config.sh

# load FSL

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh      
PATH=${FSLDIR}/bin:${PATH}         
export FSLDIR PATH

# PBS Log Info
CurrentPreproc="ICA"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error log
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${CurrentLog}

# Loop over participants, sessions (if they exist) & runs/conditions/tasks/etc
for SUB in ${SubjectID} ; do
	for TASK in ${TaskID}; do
		
		if [ $TASK == "rest" ]; then RunID="NoRun"; else source ${ScriptsPath}/preproc2_config.sh; fi
				
		for RUN in ${RunID}; do
			
			# Name of anatomical and functional images to be used.
			FuncImage="${SUB}_feat_detrended_bandpassed"												# Run specific preprocessed functional image
			AnatImage="${SUB}_T1w_brain"											# Brain extracted anatomical image
			# Path to the anatomical and functional image folders.
			AnatPath="${WorkingDirectory}/data/mri/anat/preproc/ANTs/${SUB}"					# Path for anatomical image
			if [ ${TASK} == "rest" ]; then
				FuncPath="${WorkingDirectory}/data/mri/resting_state/preproc/${SUB}"	# Path for run specific functional image
			else
				FuncPath="${WorkingDirectory}/data/mri/task/preproc/${SUB}/run-${RUN}"
			fi
			
			if [ ! -f ${FuncPath}/${FuncImage}.nii.gz ]; then
				echo "No functional image found for ${SUB} run ${RUN}"
				continue
			elif [ -d ${FuncPath}/FEAT.feat/filtered_func_data.ica ]; then
				cd ${FuncPath}/FEAT.feat/filtered_func_data.ica
				Log=`grep "finished\!" log.txt | tail -1` # Get line containing our desired text output
				if [ ! ${Log} == "finished!" ]; then
					echo "${SUB} ${TASK} ${RUN}: ICA was incomplete, deleting and re-running"
					rm -rf ${FuncPath}/FEAT.feat/filtered_func_data.ica
					cd ${FuncPath} 		# Job file can't be created in a non-existing folder
				else
					echo "${SUB} ${TASK} ${RUN}: ICA was already run. Skipping subject/run."
					continue
				fi
			fi
			
			# Variables for background image and ICA
			
			Preproc="${FuncPath}/${FuncImage}.nii.gz"							# Preprocessed data image
			BET="${AnatPath}/${AnatImage}.nii.gz"											# Brain extracted T1 image
			ANAT2FUNC="${FuncPath}/FEAT.feat/anat2func.nii.gz"										# Background image for ICA
			ICA="${FuncPath}/FEAT.feat/filtered_func_data.ica"								# Location for ICA 
			Report="${FuncPath}/FEAT.feat/filtered_func_data.ica/report.html"				# Location for ICA report links
			TR=`fslinfo ${FuncPath}/${FuncImage}.nii.gz | grep pixdim4`; TR=${TR:15}	# TR

			# Gridwise
			echo "#PBS -N ${CurrentPreproc}_${FuncImage}" 				>> job # Job name 
			echo "#PBS -l walltime=4:00:00" 							>> job # Time until job is killed 
			echo "#PBS -l mem=4gb" 										>> job # Books 4gb RAM for the job 
			echo "#PBS -m n" 											>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#PBS -o ${CurrentLog}" 								>> job # Write (output) log to group log folder 
			echo "#PBS -e ${CurrentLog}" 								>> job # Write (error) log to group log folder 

			# Initialize FSL
			# echo ". /etc/fsl/5.0/fsl.sh"								>> job # Set fsl environment 	
			echo "FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11"  >> job
			echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
			echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
			echo "export FSLDIR PATH"                               >> job
			
			## Run ICA commands
		
			# Create a condition specific background image to facilitate component rejection. Made by registering MNI image to functional image.
			if [ ! -f ${ANAT2FUNC} ]; then
				echo "flirt -in ${BET} -ref ${Preproc} -applyxfm -init ${FuncPath}/FEAT.feat/reg/highres2example_func.mat -out ${ANAT2FUNC}" 								>> job
			fi
			
			# Perform ICA			
			echo -n "melodic -i ${Preproc} -o ${ICA} --dimest=${dimestVALUE} -d ${dimensionalityVALUE} " 		>> job
			echo -n "--tr=${TR} --report --guireport=${Report} --nobet --bgthreshold=${bgthresholdVALUE} " 		>> job
			echo "--mmthresh=${mmthreshVALUE} --bgimage=${ANAT2FUNC} ${AdditionalParameters}" 					>> job
			
			# Error Log
			echo "cd ${FuncPath}/FEAT.feat/filtered_func_data.ica" 												>> job
			echo "Log=\`grep \"finished!\" log.txt | tail -1\`" 												>> job
			echo "if [ ! \"\$Log\" == \"finished!\" ]; then echo 'Error in ${FuncImage}' >> ${Error_Log}; fi"	>> job
			
			qsub job
			rm job
			
		done
	done
done
