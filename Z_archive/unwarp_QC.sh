source preproc2_config.sh

# PBS Log Info
CurrentPreproc="unwarp_QC"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi
	
for SUB in ${SubjectID} ; do
	
	# Paths
	visDir="/home/mpib/LNDG/EyeMem/data/mri/resting_state_new/preproc/${SUB}/D_unwarp_vis"
	mcDir="/home/mpib/LNDG/EyeMem/data/mri/resting_state_new/preproc/${SUB}/A_MC"
	featDir="/home/mpib/LNDG/EyeMem/data/mri/resting_state_new/preproc/${SUB}/C_FEAT.feat"
	
	#create outdir
	if [ ! -d ${visDir} ]; then mkdir -p ${visDir}; chmod 770 ${visDir}; fi
		
	#Gridwise
	echo "#PBS -N ${CurrentPreproc}_${SUB}" 						>> job # Job name 
	echo "#PBS -l walltime=12:00:00" 									>> job # Time until job is killed 
	echo "#PBS -l mem=5gb" 												>> job # Books 4gb RAM for the job 
	echo "#PBS -m n" 													>> job # Email notification on abort/end, use 'n' for no notification 
	echo "#PBS -o ${CurrentLog}" 										>> job # Write (output) log to group log folder 
	echo "#PBS -e ${CurrentLog}" 										>> job # Write (error) log to group log folder 
		
	echo "cd ${visDir}" >> job
	
	echo "module load fsl/5.0" >> job
	
	# get input images
	echo "fslroi ${mcDir}/func_data_mc ${visDir}/example_func_distorted 294 1" >> job
	
	echo "cp ${featDir}/reg/highres_head.nii.gz ${visDir}/highres_head.nii.gz" >> job
	echo "cp ${featDir}/reg/highres.nii.gz ${visDir}/highres.nii.gz" >> job
	echo "cp ${featDir}/reg/example_func2highres_fast_wmseg.nii.gz ${visDir}/example_func2highres_fast_wmseg.nii.gz" >> job
	echo "cp ${featDir}/reg/example_func2highres.nii.gz ${visDir}/example_func_undistorted2highres.nii.gz" >> job
	
	# register distorted func to T1
	echo "epi_reg --epi=example_func_distorted --t1=highres_head --t1brain=highres --wmseg=example_func2highres_fast_wmseg --out=example_func_distorted2highres" >> job
	
	# prepare distorted overlay image
	echo "overlay  0 0 example_func_distorted2highres -a example_func_distorted2highres_fast_wmedge 0.001 10 grot" >> job
	
	echo "slicer grot -c -s 3 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png" >> job
	
	echo "pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png warped_edges.gif" >> job
	
	echo "rm grot.nii.gz sla.png slb.png slc.png sld.png sle.png slf.png slg.png slh.png sli.png slj.png slk.png sll.png" >> job
	
	# prepare undistorted overlay image
	echo "overlay  0 0 example_func_undistorted2highres -a example_func_distorted2highres_fast_wmedge 0.001 10 grot" >> job
	
	echo "slicer grot -s 3 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png" >> job
	
	echo "pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png unwarped_edges.gif" >> job
	
	echo "rm grot.nii.gz sla.png slb.png slc.png sld.png sle.png slf.png slg.png slh.png sli.png slj.png slk.png sll.png" >> job
	
	# prepare gif animation
	echo "whirlgif -o warping_movie.gif -time 50 -loop 0 warped_edges.gif unwarped_edges.gif 2>&1" >> job
	
	qsub job
	rm job
	
done