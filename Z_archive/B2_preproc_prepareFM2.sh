#!/bin/bash

source preproc2_config.sh

# PBS Log Info
CurrentPreproc="prepareFM_conserv"
CurrentLog="${LogPath}/${CurrentPreproc}"

if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi
	
for SUB in ${SubjectID} ; do
	
	# Path to the gre image folder.
	FieldOrigPath="${DataPath}/${SUB}/fmap"		# Path for field images
	
	# Name of phase image to be used.
	PhaseImage="${SUB}_phasediff" 
	
	# Name of output preprocessing dir		
	FMpath="${WorkingDirectory}/data/mri/fmap/preproc/${SUB}/ants+fsl_bet_ero"
		
	# Gridwise
	echo "#PBS -N ${CurrentPreproc}_${SUB}" 	>> job # Job name 
	echo "#PBS -l walltime=12:00:00" 						>> job # Time until job is killed 
	echo "#PBS -l mem=4gb" 								>> job # Books 10gb RAM for the job 
	echo "#PBS -m n" 										>> job # Email notification on abort/end, use 'n' for no notification 
	echo "#PBS -o ${CurrentLog}" 							>> job # Write (output) log to group log folder 
	echo "#PBS -e ${CurrentLog}" 							>> job # Write (error) log to group log folder 
	
	echo "module load fsl/5.0" 							>> job
	
	#${FSLDIR}/bin/imcp ${PhaseInputName} ${WD}/Phase

	echo "fsl_prepare_fieldmap SIEMENS ${FieldOrigPath}/${PhaseImage}.nii.gz ${FMpath}/${SUB}_fmap_MeanMagnitude_brain.nii.gz ${FMpath}/${SUB}_fmap_rads 2.46"		>> job

	qsub job
	rm job
	
done