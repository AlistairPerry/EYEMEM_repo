source preproc2_config.sh

# PBS Log Info
CurrentPreproc="mc+unwarping"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi
	
# convert epi spacing from ms to sec
EpiSpacing_sec=$(echo "${EpiSpacing}*10^-3" | bc -l)

example_func_vol=$(echo "(${TotalVolumes}-${DeleteVolumes})/2" | bc) # volume number for example func

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
				FuncPath="${WorkingDirectory}/data/mri/resting_state_new/preproc/${SUB}"
			elif [ ${TASK} == "eyemem" ]; then
				FuncPath="${WorkingDirectory}/data/mri/task/preproc/${SUB}/run-${RUN}"
			fi
			
			if [ ! -f ${OriginalPath}/${FuncImage}.nii.gz ]; then
				continue
			elif [ -d ${FuncPath}/B_unwarping ]; then
				if [ -f ${FuncPath}/B_unwarping/func_data_mc_unwarp.nii.gz ]; then
					continue
				else
					rm -rf ${FuncPath}/A_MC
					rm -rf ${FuncPath}/B_unwarp
				fi
			fi
			
			FMpath="${WorkingDirectory}/data/mri/fmap/preproc/${SUB}/ants+fsl_bet_ero"
			FMname="${SUB}_fmap_rads"
			
			# Create run specific directories for preprocessing images and files
			if [ ! -d ${FuncPath}/A_MC ]; then mkdir -p ${FuncPath}/A_MC; fi
			if [ ! -d ${FuncPath}/B_unwarp ]; then mkdir -p ${FuncPath}/B_unwarp; fi
			
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
			echo "#PBS -l mem=5gb" 												>> job # Books 4gb RAM for the job 
			echo "#PBS -m n" 													>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#PBS -o ${CurrentLog}" 										>> job # Write (output) log to group log folder 
			echo "#PBS -e ${CurrentLog}" 										>> job # Write (error) log to group log folder 

			echo ". /etc/fsl/5.0/fsl.sh"										>> job # Set fsl environment 	
			#echo "FSLDIR=/home/mpib/LNDG/toolboxes/FSL/fsl-5.0.11"  >> job
			#echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
			#echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
			#echo "export FSLDIR PATH"                               >> job
			
			# motion correction
			echo "cd ${FuncPath}/A_MC" >> job
			
			echo "cp ${OriginalPath}/${FuncImage}.nii.gz ${FuncPath}/A_MC/func_data_raw.nii.gz" >> job
			echo "fslroi func_data_raw func_data_raw ${DeleteVolumes} -1" >> job # delete first 12 volumes
			echo "fslroi func_data_raw example_func ${example_func_vol} 1" >> job
			
			
			echo "mcflirt -in func_data_raw -out func_data_mc -mats -plots -reffile example_func -rmsrel -rmsabs -spline_final" >> job
			
			# unwarping
			echo "cd ${FuncPath}/B_unwarp" >> job
			
			echo "cp ${FMpath}/${FMname}.nii.gz ${FuncPath}/B_unwarp/fmap.nii.gz" >> job
			
			echo "fugue -i ../A_MC/func_data_mc --dwell=${EpiSpacing_sec} --loadfmap=fmap -u func_data_mc_unwarp --unwarpdir=y-" >> job

			qsub job
			rm job
			
		done
	done
done