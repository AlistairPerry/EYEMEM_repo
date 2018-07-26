#!/bin/bash

#### From HCP Pipeline ###

${FSLDIR}/bin/fslmaths ${MagnitudeInputName} -Tmean ${WD}/Magnitude

### They say BET, I'm going to use ANTs bra

#${FSLDIR}/bin/bet ${WD}/Magnitude ${WD}/Magnitude_brain -f 0.35 -m #Brain extract the magnitude image


source preproc_config.sh

# PBS Log Info
CurrentPreproc="BET/ANTs"
CurrentLog="${LogPath}/${CurrentPreproc}"

if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Loop over participants & sessions (if they exist)
for SUB in ${SubjectID} ; do
	if [ -z "${SessionID}" ]; then Session="NoSessions"; SessionFolder=""; SessionName=""
	else Session="${SessionID}"
	fi
	for SES in ${Session}; do
		if [ "${Session}" != "NoSessions" ]; then
			if [ ! -d ${ProjectDirectory}/data/${SUB}/${SES} ]; then continue
			else SessionFolder="${SES}/"; SessionName="${SES}_"
			fi			
		fi	
		
		# Path to the anatomical image folder.
		AnatPath="${ProjectDirectory}/data/${SUB}/${SessionFolder}mri/t1"		# Path for anatomical image	
		# Name of anatomical image to be used.
		AnatImage="${SUB}_${SessionName}t1" 									# Original anatomical image, no extraction performed
		# Output path for ANTs procedure
		ANTsPath="${AnatPath}/tempANTs/${AnatImage}_ANTs_"
		# Start log
		StartLog="${ANTsPath}started.txt"
		# Error message if ANTs did not produce the expected output
		CrashLog="${ANTsPath}failed.txt"
		
		# If anat files have not been properly renamed.
		cd ${AnatPath}
		if [ ! -f ${AnatImage}.nii.gz ]; then
			AnatImage=`ls co*`														
		fi
		
		if [ ! -f ${AnatPath}/${AnatImage}.nii.gz ]; then   		# Verifies if the anatomical image exists. If it doesn't, the for loop stops here and continues with the next item. 
			echo "No mprage: ${SUB} cannot be processed"
			continue
		elif [ -f ${AnatPath}/${AnatImage}_brain.nii.gz ]; then 	# Verify if brain extracted image has been selected, if so, stop here.
			continue
		elif [ -f ${ANTsPath}BrainExtractionBrain.nii.gz ]; then 	# Verify if ANTs output was already created
			continue
		elif [ ! -f ${ANTsPath}BrainExtractionBrain.nii.gz ]; then
			if [ -f ${CrashLog} ]; then 							# Verify if crash log exists, if so, delete intermediary ANTs files and re-run ANTs.
				rm -rf ${AnatPath}/tempANTs 				
			elif [ -f ${StartLog} ]; then 							# Verify if ANTs job started. Could be problematic if job did not finish.
				continue
			fi
		fi
		
		# ANTs-specific file paths
		TemplatePath="${ANTsPath}/${SelectedTemplate}" 					# Directory for ANTs template to be used.
		TemplateImage="${TemplatePath}/T_template0.nii.gz" 											# ANTs bet template image (e.g. averaged anatomical image) - mandatory
		ProbabilityImage="${TemplatePath}/T_template0_BrainCerebellumProbabilityMask.nii.gz" 		# ANTs bet brain probability image of the template image - mandatory
		RegistrationMask="${TemplatePath}/T_template0_BrainCerebellumRegistrationMask.nii.gz" 		# ANTs bet brain mask of the template image (i.e. rough binary mask of brain location) - optional (recommended)
		
		# Gridwise
		echo "#PBS -N ${CurrentPreproc}_${SessionName}${SUB}" 	>> job # Job name 
		echo "#PBS -l walltime=03:00:00" 						>> job # Time until job is killed 
		echo "#PBS -l mem=10gb" 								>> job # Books 10gb RAM for the job 
		echo "#PBS -m n" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#PBS -o ${CurrentLog}" 							>> job # Write (output) log to group log folder 
		echo "#PBS -e ${CurrentLog}" 							>> job # Write (error) log to group log folder 
    	
		echo "sleep $(( RANDOM % 120 ))"						>> job # Sleep for a random period between 1-60 seconds, used to avoid interfierence when running antsBrainExtraction.sh
		     	
    	echo "module load ants/2.2.0" 							>> job
		
		# Create temporary folder.
		echo "mkdir ${AnatPath}/tempANTs"						>> job
		echo "echo 'ANTs will start now' >> ${StartLog}"		>> job
		
		# Perform Brain Extraction
		
		echo -n "antsBrainExtraction.sh -d ${ImageDimension} -a ${AnatPath}/${AnatImage}.nii.gz -e ${TemplateImage} " 	>> job
		echo  "-m ${ProbabilityImage} -f ${RegistrationMask} -k ${KeepTemporaryFiles} -o ${ANTsPath}" 					>> job

		# If the final ANTs output isn't created, write a text file to be used as a verification of the output outcome.
		echo "if [ ! -f ${ANTsPath}BrainExtractionBrain.nii.gz ]; then echo 'BrainExtractionBrain file was not produced.' >> ${CrashLog}; fi" >> job

${FSLDIR}/bin/imcp ${PhaseInputName} ${WD}/Phase
${FSLDIR}/bin/fsl_prepare_fieldmap SIEMENS ${WD}/Phase ${WD}/Magnitude_brain   2.46

		echo "cd ${AnatPath}"									>> job
		echo "chmod -R 770 ."  									>> job

		qsub job
		rm job
	done
done
