#!/bin/bash

# FEAT: Smoothing and Motion Correction

# NOTE1: This uses a template file which already has 'dummyCode' specified for the variables which will be replaced with the appropriate study/subject/session/run information.

# NOTE 2: The template specifies the anatomical image (which should already be Brain Extracted) for registration. This will not perform the registration, only create registration matrices which are necesarry for the Automated Denoising procedure (FIX).

# NOTE 3: The Nifti Toolbox might require you to reslice images, thus altering their dimensions. The files that FIX requires must be of the same size as the registration matrices produced by FEAT. For this reason, one must VERIFY beforehand if the files will require reslicing in order to perform it before FEAT. Currently (19.06.17), all processes that require the Nifti toolbox operare with load_untouch_nii and save_untouch_nii, thus rendering this point moot, but this might change in the future.

source preproc2_config.sh

# PBS Log Info
CurrentPreproc="FEAT_noUnwarp"
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
			# Name of brain extracted anatomical and functional image to be used.
			AnatImage="${SUB}_T1w_brain"
			
			# Path to the original functional image folder.
			OriginalPath="${DataPath}/${SUB}/func"
			# Path to the pipeline specific folder.
			if [ ${TASK} == "rest" ]; then
				FuncPath="${WorkingDirectory}/data/mri/resting_state_noUnwarp/preproc/${SUB}"
			elif [ ${TASK} == "eyemem" ]; then
				FuncPath="${WorkingDirectory}/data/mri/task/preproc/${SUB}/run-${RUN}"
			fi
			# Path to the anatomical image
			AnatPath="${WorkingDirectory}/data/mri/anat/preproc/ANTs/${SUB}"
			
			if [ ! -f ${OriginalPath}/${FuncImage}.nii.gz ]; then
				continue
			elif [ ! -f ${AnatPath}/${AnatImage}.nii.gz ]; then
				echo "Anatomical image for ${SUB} not found: ${AnatPath}/${AnatImage}.nii.gz does not exist, FEAT was halted" >> ${Error_Log}
				continue
			elif [ -d ${FuncPath}/FEAT.feat ]; then
				if [ -d ${FuncPath}/FEAT+.feat ]; then
					rm -rf ${FuncPath}/FEAT+.feat
				fi
				if [ -f ${FuncPath}/FEAT.feat/prefiltered_func_data.nii.gz ]; then
					rm -rf ${FuncPath}/FEAT.feat
				elif [ ! -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ]; then
					rm -rf ${FuncPath}/FEAT.feat
				elif [ -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ]; then
					continue
				fi
			fi
			
			# Create run specific directory for preprocessing images and files
			if [ ! -d ${FuncPath} ]; then mkdir -p ${FuncPath}; fi
			
			# TODO: Set different image volume amount/volumes to be deleted for resting state and runs (or different runs)
			# NOTE: Only necessary if niftis have different total volumes.
			#if [ "${RUN}" == "restingstate" ]; then
			#	TotalVolumes="600"
			#	DeleteVolumes="4"
			#else
			#	TotalVolumes="474"
			#	DeleteVolumes="12"
			#fi
			
			# Roundabout way for getting TR & Volumes
			# TotalVolumes=`fslinfo ${OriginalPath}/${FuncImage}.nii.gz | grep -w dim4`; TotalVolumes=`${TotalVolumes:15}`
			# TR=`fslinfo ${OriginalPath}/${FuncImage}.nii.gz | grep pixdim4`; TR=`${TR:15}`
			
			# Gridwise
			echo "#PBS -N ${CurrentPreproc}_${FuncImage}" 						>> job # Job name 
			echo "#PBS -l walltime=12:00:00" 									>> job # Time until job is killed 
			echo "#PBS -l mem=4gb" 												>> job # Books 4gb RAM for the job 
			echo "#PBS -m n" 													>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#PBS -o ${CurrentLog}" 										>> job # Write (output) log to group log folder 
			echo "#PBS -e ${CurrentLog}" 										>> job # Write (error) log to group log folder 

			#echo ". /etc/fsl/5.0/fsl.sh"										>> job # Set fsl environment 	
			echo "module load fsl/5.0"  >> job

			# Create a designfile from the common template file, which should be saved in the scripts folder. 
			echo "cp ${ScriptsPath}/D_feat_template.fsf  ${FuncPath}/${FuncImage}.fsf"     	>> job

			# Adjust paths to the location of the fsf file
			echo "cd ${FuncPath}"           												>> job

			## This will replace the dummy code with the appropriate image, study, subject, session & run specific information.
				# The 'g' option will replace all instances of the dummy code with the required variable.
				# As a side note, we're using the '|' character so as to avoid issues when replacing strings which include slashes.
			
			# Primary Directories	
			echo "sed  -i 's|dummyFEAT|'${FuncPath}/FEAT.feat'|g'  				${FuncImage}.fsf"          	>> job	
			echo "sed  -i 's|dummyOriginal|'${OriginalPath}/${FuncImage}'|g'  	${FuncImage}.fsf"      		>> job
			echo "sed  -i 's|dummyAnatomical|'${AnatPath}/${AnatImage}'|g'  	${FuncImage}.fsf"     		>> job
			echo "sed  -i 's|dummyStandard|'${MNIImage}'|g'						${FuncImage}.fsf"          	>> job
			# Primary Parameters
			echo "sed  -i 's|dummyToggleMCFLIRT|'${ToggleMCFLIRT}'|g'  			${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyBETFunc|'${BETFunc}'|g'  						${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyTR|'${TR}'|g'  								${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyTotalVolumes|'${TotalVolumes}'|g'  			${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyDeleteVolumes|'${DeleteVolumes}'|g'  			${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyHighpassFEAT|'${HighpassFEAT}'|g'  			${FuncImage}.fsf" 			>> job
            echo "sed  -i 's|dummySmoothingKernel|'${SmoothingKernel}'|g'  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyRegisterStructDOF|'${RegisterStructDOF}'|g'  	${FuncImage}.fsf" 			>> job
			# Secondary Parameters. Not usually used in our analysis.
				# Nonlinear Registration
			echo "sed  -i 's|dummyNonLinearReg|'${NonLinearReg}'|g'  			${FuncImage}.fsf" 			>> job
            echo "sed  -i 's|dummyNonLinearWarp|'${NonLinearWarp}'|g'  			${FuncImage}.fsf" 			>> job
				# B0 unwarping
			if [ "${Unwarping}" == "1" ]; then
				FieldRad="${WorkingDirectory}/data/mri/fmap/preproc/${SUB}/ants+fsl_bet_ero/${SUB}_fmap_rads"
				FieldMapBrain="${WorkingDirectory}/data/mri/fmap/preproc/${SUB}/ants+fsl_bet_ero/${SUB}_fmap_MeanMagnitude_brain"
			else 
				FieldRad="Unused" 
				FieldMapBrain="Unused" 
			fi 
			echo "sed  -i 's|dummyUnwarping|'${Unwarping}'|g'  														  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyFieldRad|'${FieldRad}'|g'  														  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyFieldMapBrain|'${FieldMapBrain}'|g'  												  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyEpiSpacing|'${EpiSpacing}'|g'  													  		${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyEpiTE|'${EpiTE}'|g'  																  		${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyUnwarpDir|'${UnwarpDir}'|g'  														  		${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummySignalLossThresh|'${SignalLossThresh}'|g'  										  		${FuncImage}.fsf"           >> job
				# Other Parameters
	        echo "sed  -i 's|dummyIntensityNormalization|'${IntensityNormalization}'|g'										${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummySliceTimingCorrection|'${SliceTimingCorrection}'|g' 										${FuncImage}.fsf" 			>> job
			
			# Run feat command.                                                                    
			echo "feat ${FuncImage}.fsf"           										>> job
			
			# Error log
			echo "if [ ! -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ];"  		>> job
			echo "then echo 'Error in ${FuncImage}' >> ${Error_Log}; fi"				>> job
			
			qsub job
			rm job
			
		done
	done
done
