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

Loop over participants & sessions (if they exist)
for SUB in ${SubjectID} ; do
	if [ -z "${SessionID}" ]; then Session="NoSessions"; SessionFolder=""; SessionName=""
	else Session="${SessionID}"
	fi
	for SES in ${Session}; do
		if [ "${Session}" != "NoSessions" ]; then
			if [ ! -d ${ProjectDirectory}/data/${SUB}/${SES} ]; then continue
			else SessionFolder="${SES}/"; SessionName="${SES}_"
			fi			dddd
		fi	
		
		# Path to the anatomical image folder.
		FieldPath="${ProjectDirectory}/data_renamed/${SUB}/mri/t1"		# Path for field images	
		
		# Name of phase image to be used.
		PhaseImage="${SUB}_grephase" 	
		
		# Name of magnitudue image to be used
		MagImage="${SUB}_gremag" 
		
		#divide by two
		
		# Output path for ANTs procedure
		#ANTsPath="${AnatPath}/tempANTs/${AnatImage}_ANTs_"
		
		# Start log
		StartLog="${FMpath}started.txt"
		# Error message if ANTs did not produce the expected output
		CrashLog="${FMpath}failed.txt"
		
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
		echo "mkdir ${FMPath}/tempANTs"						>> job
		echo "echo 'ANTs will start now' >> ${StartLog}"		>> job
		
		# Perform Brain Extraction
		
		echo -n "antsBrainExtraction.sh -d 3 -a ${FMPath}/${AnatImage}.nii.gz -e ${TemplateImage} " 	>> job
		echo  "-m ${ProbabilityImage} -f ${RegistrationMask} -k ${KeepTemporaryFiles} -o ${FMPath}" 					>> job

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
