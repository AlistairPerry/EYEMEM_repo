#!/bin/bash

## Brain Extraction (BET). Create brain extracted images using desired parameters.

# We use various parameters in the lab, mainly the following:
	# -f; fractional intensity threshold: This determines the volume within the skull that actually encompasses the brain.; default= 0.5; smaller values give larger brain outline estimates
	# -g; vertical gradient in fractional intensity threshold (-1->1); Normally we use a negative value to remove non-brain structures from the base of the image.; default= 0; positive values give larger brain outline at bottom, smaller at top
	# -R; "robust" brain centre estimation. This option interatively resets the 'centre-of-gravity' as it performs the brain estimation, so as to achieve a more accurate fit of the image. 

# It's recommended to try various paramenters with a few subjects from your study in order to verify which are more appropriate for your particular dataset. Before we have decided which image to use for the participant, we create a series of BET images with different paramenters and the naming of these files corresponds to the parameters used in their creation. For example a BET image which was created using the -f parameter with a value of 0.3 and a -g parameter of -.25 we would name the image as 'ANATOMICAL_IMAGE' and append the suffix '_brainf03g025'. After we decide which parameter(s) are appropriate for the subject, we rename the file using the standard naming: 'ANATOMICAL_IMAGE' and the suffix '_brain.nii.gz'

# When deciding which parameters to use for the participant, always choose to be more liberal. That is to say, choose to include voxels which aren't brain matter if it's necessary to capture the totality of the brain structures one is interested in analyzing.

# Keep record of the final paremeters used for each participant.

source preproc2_config.sh

# Test
#SubjectID="EYEMEMtest"

# PBS Log Info
CurrentPreproc="BET/FSL"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Loop over participants & sessions (if they exist)
for SUB in ${SubjectID} ; do

		# Path to the anatomical image folder.
		AnatPath="${WorkingDirectory}/data/mri/fmap/preproc/${SUB}/bet_fsl"		# Path for anatomical image	
		# Name of anatomical image to be used.
		AnatImage="${SUB}_fmap_MeanMagnitude" 									# Original anatomical image, no extraction performed
		
		# Verifies if the anatomical image exists. If it doesn't, the for loop stops here and continues with the next item.
		if [ ! -f ${AnatPath}/${AnatImage}.nii.gz ]; then
			echo "No mprage: ${SUB} cannot be processed"
			continue
		fi
		
		# Gridwise
		echo "#PBS -N ${CurrentPreproc}_${SUB}" 				>> job # Job name 
		echo "#PBS -l walltime=0:30:00" 						>> job # Time until job is killed 
		echo "#PBS -l mem=2gb" 									>> job # Books 4gb RAM for the job 
		echo "#PBS -m n" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#PBS -o ${CurrentLog}" 							>> job # Write (output) log to group log folder 
		echo "#PBS -e ${CurrentLog}" 							>> job # Write (error) log to group log folder 
    	
		echo ". /etc/fsl/5.0/fsl.sh"							>> job # Set fsl environment 	
		
		echo "cd ${AnatPath}"									>> job
		echo "mkdir ${AnatPath}/temp"							>> job

		# Perform Brain Extractions
		
			# Parameters:
			# bet <input> <output> [options]

		# First Batch 		                                                                                  	    	
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g25_brain.nii.gz -f 0.1 -g -0.25" 				>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f15g25_brain.nii.gz -f 0.15 -g -0.25" 				>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f2g25_brain.nii.gz -f 0.2 -g -0.25" 				>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f25g25_brain.nii.gz -f 0.25 -g -0.25" 				>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f3g25_brain.nii.gz -f 0.3 -g -0.25" 				>> job
		                                                                                  	    	
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1_brain.nii.gz -f 0.1" 							>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f15_brain.nii.gz -f 0.15" 							>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f2_brain.nii.gz -f 0.2" 							>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f25_brain.nii.gz -f 0.25" 							>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f3_brain.nii.gz -f 0.3" 							>> job
		                                                                                  	    	
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1R_brain.nii.gz -f 0.1 -R" 						>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f15R_brain.nii.gz -f 0.15 -R" 						>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f2R_brain.nii.gz -f 0.2 -R" 						>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f25R_brain.nii.gz -f 0.25 -R" 						>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f3R_brain.nii.gz -f 0.3 -R" 						>> job
		                                                                                 	    	
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f07_brain.nii.gz -f 0.07" 							>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f05_brain.nii.gz -f 0.05" 							>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f05R_brain.nii.gz -f 0.05 -R" 						>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f07R_brain.nii.gz -f 0.07 -R" 						>> job
		
		# Second Batch
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f07g25R_brain.nii.gz -f 0.07 -g -0.25 -R"	 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f07g25_brain.nii.gz -f 0.07 -g -0.25" 				>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f05g25R_brain.nii.gz -f 0.05 -g -0.25 -R"	 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f05g25_brain.nii.gz -f 0.05 -g -0.25" 				>> job
                                                                                 	
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g25R_brain.nii.gz -f 0.1 -g -0.25 -R" 			>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f15g25R_brain.nii.gz -f 0.15 -g -0.25 -R"	 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f2g25R_brain.nii.gz -f 0.2 -g -0.25 -R" 			>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f25g25R_brain.nii.gz -f 0.25 -g -0.25 -R"	 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f3g25R_brain.nii.gz -f 0.3 -g -0.25 -R" 			>> job

		# Third Batch 
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g25r60_brain.nii.gz -f 0.1 -g -0.25 -r 60" 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g15r60_brain.nii.gz -f 0.1 -g -0.15 -r 60" 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g25r55_brain.nii.gz -f 0.1 -g -0.25 -r 55" 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g15r55_brain.nii.gz -f 0.1 -g -0.15 -r 55" 		>> job		
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g25r65_brain.nii.gz -f 0.1 -g -0.25 -r 65" 		>> job
		echo "bet ${AnatImage} ${AnatPath}/temp/${AnatImage}_f1g15r65_brain.nii.gz -f 0.1 -g -0.15 -r 65" 		>> job		                                           
		
		echo "chmod -R 770 ."  		>> job

		#qsub job
		#rm job
done

