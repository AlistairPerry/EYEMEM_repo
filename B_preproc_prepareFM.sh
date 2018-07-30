#!/bin/bash

source preproc2_config.sh

# PBS Log Info
#CurrentPreproc="greprep"
#CurrentLog="${LogPath}/${CurrentPreproc}"

#if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

Loop over participants & sessions (if they exist)

for SUB in ${SubjectID} ; do
		
		# Path to the gre image folder.
		FieldOrigPath="${ProjectDirectory}/data_renamed/${SUB}/mri/gre"		# Path for field images	
		
		# Name of phase image to be used.
		PhaseImage="${SUB}_grephase" 	
		
		# Name of magnitudue image to be used
		MagImage="${SUB}_gremag" 
				
		# Name of output preprocessing dir		
		FMpath="${ProjectDirectory}/data_renamed/${SUB}/mri/greprep"

		# Output path for field map prep procedure with ANTs (i.e. brain extraction)
		ANTsPath="${FMpath}/tempANTs/FM_ANTs_"
		
		# Start log
		StartLog="${ANTsPath}started.txt"
		# Error message if ANTs did not produce the expected output
		CrashLog="${ANTsPath}failed.txt"
		
		# ANTs-specific file paths
		TemplatePath="smb://mpib-berlin.mpg.de/fb-lip/lndg/Standards/ANTS/MICCAI2012-Multi-Atlas-Challenge-Data" #! will need to fix					# Directory for ANTs template to be used.
		TemplateImage="${TemplatePath}/T_template0.nii.gz" 											# ANTs bet template image (e.g. averaged anatomical image) - mandatory
		ProbabilityImage="${TemplatePath}/T_template0_BrainCerebellumProbabilityMask.nii.gz" 		# ANTs bet brain probability image of the template image - mandatory
		RegistrationMask="${TemplatePath}/T_template0_BrainCerebellumRegistrationMask.nii.gz" 		# ANTs bet brain mask of the template image (i.e. rough binary mask of brain location) - optional (recommended)
		
		# Gridwise
		echo "#PBS -N ${CurrentPreproc}_${SessionName}${SUB}" 	>> job # Job name 
		echo "#PBS -l walltime=12:00:00" 						>> job # Time until job is killed 
		echo "#PBS -l mem=10gb" 								>> job # Books 10gb RAM for the job 
		echo "#PBS -m n" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#PBS -o ${CurrentLog}" 							>> job # Write (output) log to group log folder 
		echo "#PBS -e ${CurrentLog}" 							>> job # Write (error) log to group log folder 
    	
		echo "sleep $(( RANDOM % 120 ))"						>> job # Sleep for a random period between 1-60 seconds, used to avoid interfierence when running antsBrainExtraction.sh
		     	
    		echo "module load ants/2.2.0" 							>> job
		
		# Create temporary folder.
		echo "mkdir -p ${FMPath}/tempANTs"						>> job
		echo "echo 'ANTs will start now' >> ${StartLog}"		>>	job
		
		#### From HCP Pipeline ###
		
		echo "cd ${FMpath}"		>> job
		
		#divide by two

		echo "fslmaths ${FieldOrigPath}/${MagImage} -Tmean MagnitudeMean" 		>> job

		### They say BET, I'm going to use ANTs bra

		#${FSLDIR}/bin/bet ${WD}/Magnitude ${WD}/Magnitude_brain -f 0.35 -m #Brain extract the magnitude image
		
		# Perform Brain Extraction
		
		echo -n "antsBrainExtraction.sh -d 3 -a MagnitudeMean.nii.gz -e ${TemplateImage} " 	>> job
		echo  "-m ${ProbabilityImage} -f ${RegistrationMask} -k ${KeepTemporaryFiles} -o ${ANTsPath}" 					>> job

		# If the final ANTs output isn't created, write a text file to be used as a verification of the output outcome.
		echo "if [ ! -f ${ANTsPath}BrainExtractionBrain.nii.gz ]; then echo 'BrainExtractionBrain file was not produced.' >> ${CrashLog}; fi" >> job

		echo "cp ${ANTsPath}BrainExtractionBrain.nii.gz ${FMPath}/Magnitude_brain.nii.gz"		>> job

		#${FSLDIR}/bin/imcp ${PhaseInputName} ${WD}/Phase

		echo "fsl_prepare_fieldmap SIEMENS ${PhaseInputName} ${FMPath}/Magnitude_brain 2.46"		>> job

		## echo "cd ${FMPath}"									>> job
		echo "chmod -R 770 ."  									>> job

		qsub job
		rm job
	done
done
