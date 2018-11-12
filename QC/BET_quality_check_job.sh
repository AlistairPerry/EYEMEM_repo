#PBS -N BET_QC 	  # Job name 
#PBS -l walltime=12:00:00 						  # Time until job is killed 
#PBS -l mem=4gb 								  # Books 10gb RAM for the job 
#PBS -m n										  # Email notification on abort/end, use 'n' for no notification 
#PBS -o /home/mpib/LNDG/EyeMem/study_information/B_logs/BET_QC 							  # Write (output) log to group log folder 
#PBS -e /home/mpib/LNDG/EyeMem/study_information/B_logs/BET_QC 							  # Write (error) log to group log folder 

#!/bin/bash
# 01.06.18 Creating quality check report for brain extraction by Alex

source /home/mpib/LNDG/EyeMem/study_information/A_scripts/preproc2_config.sh

if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

#Output path must be an empty folder!
OutPath_anat="${WorkingDirectory}/data/mri/anat/preproc/ANTs/QC"
OutPath_fmap="${WorkingDirectory}/data/mri/fmap/preproc/ANTs/QC"

if [ ! -d ${OutPath_anat} ]; then mkdir -p ${OutPath_anat}; chmod 770 ${OutPath_anat}; fi
if [ ! -d ${OutPath_fmap} ]; then mkdir -p ${OutPath_fmap}; chmod 770 ${OutPath_fmap}; fi

 module load fsl/5.0 
 cd ${ScriptsPath}

# T1
 cd ${OutPath_anat} 

#cycle over subjects
 for SUB in ${SubjectID}; do

# raw T1
 T1=${DataPath}/${SUB}/anat/${SUB}_T1w.nii.gz

# Brain extracted T1 (ANTS bet output)
 T1_bet=${WorkingDirectory}/data/mri/anat/preproc/ANTs/${SUB}/${SUB}_T1w_brain.nii.gz	 

#overlay of brain extraction
 overlay 1 1 ${T1} -a ${T1_bet} 1 10 ${OutPath_anat}/${SUB}_anat_bet_overlay.nii.gz 
 
 done

 overlays=`ls *_anat_bet_overlay.nii.gz`	 

#create report
 slicesdir ${overlays}

#delete intermediate niftis
 rm ${overlays}	
 
#clean up
cd ${OutPath_anat}/slicesdir

overlays_png=`ls *_anat_bet_overlay.png`
mv ${overlays_png} ${OutPath_anat}

cd ${OutPath_anat}

mv ${OutPath_anat}/slicesdir/index.html ${OutPath_anat}/index.html
rm -r ${OutPath_anat}/slicesdir

# fmap
 cd ${OutPath_fmap}	 

#cycle over subjects
 for SUB in ${SubjectID}; do	 

# raw mag image
 fmap_mag=${WorkingDirectory}/data/mri/fmap/preproc/${SUB}/${SUB}_fmap_MeanMagnitude.nii.gz

# Brain extracted mag image (ANTS bet output)
 fmap_mag_bet=${WorkingDirectory}/data/mri/fmap/preproc/${SUB}/${SUB}_fmap_MeanMagnitude_brain.nii.gz	 

#overlay of brain extraction
 overlay 1 1 ${fmap_mag} -a ${fmap_mag_bet} 1 10 ${OutPath_fmap}/${SUB}_fmap_bet_overlay.nii.gz 	 

 done
 
 overlays=`ls *_fmap_bet_overlay.nii.gz`	 

#create report
 slicesdir ${overlays}	

#delete intermediate niftis
 rm ${overlays}
 
 #clean up
 cd ${OutPath_fmap}/slicesdir
 
 overlays_png=`ls *_fmap_bet_overlay.png`
 mv ${overlays_png} ${OutPath_fmap}
 
 cd ${OutPath_fmap}	
 
 mv ${OutPath_fmap}/slicesdir/index.html ${OutPath_fmap}/index.html
 rm -r ${OutPath_fmap}/slicesdir