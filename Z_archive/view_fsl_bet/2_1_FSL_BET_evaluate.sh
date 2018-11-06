#!/bin/bash

# This script uses fsleyes to view multiple BET images for a participant, with the purpose of evaluating different BET parameters and determining which one should be used as the anatomical image (or the <subjectID>_t1_brain.nii.gz image) for use during the preprocessing pipeline.

# Arguments:
#	Example - evaluate_bet.sh DataDirectory SubjectID Options
# 	X. DataDirectory 	string, directory of all subject data
#	1. SubjectID: 		string
#	2. Options: 		string
#		1:					basic f parameters (3, 2.5, 2, 1.5, 1)
#		2: 					basic f parameters with g25 parameter
#		3: 					basic f parameters with R parameter
#		4: 					extremely liberal f parameters (0.07/0.05) with & without R parameter
# 		5: 					all previous parameter combinations (recommended default usage option)
# 		6: 					all f parameters with g25 & R option
# 		7: 					f1 with g25/15 & r 65/60/55 parameters
# 		8: 					all parameter combinations (recommended default for older adults)

clear

printf "Preparing BET images for Subject $2 \n"

#Example of DataDir: /Users/ramirez/MacFusion/LNDG/StateSwitch/WIP/preproc/B_data/D_preproc

DataDir=$1
SubjectID=$2

# These are parameter combinations created by 01_preproc_BET.sh 
Params1="f1 f15 f2 f25 f3"
Params2="f1g25 f15g25 f2g25 f25g25 f3g25"
Params3="f1R f15R f2R f25R f3R"
Params4="f07 f07R f05 f05R"
Params5="f07 f07R f05 f05R f1R f15R f1g25 f15g25 f1 f15 f2R f25R f2g25 f25g25 f2 f25 f3R f3g25 f3"
Params6="f07g25R f07g25 f05g25R f05g25 f1g25R f15g25R f2g25R f25g25R f3g25R"
Params7="f1g25r60 f1g15r60 f1g25r55 f1g15r55 f1g25r65 f1g15r65"
Params8="f1g25r60 f1g15r60 f1g25r55 f1g15r55 f1g25r65 f1g15r65 f07g25R f07g25 f05g25R f05g25 f1g25R f15g25R f2g25R f25g25R f3g25R f07 f07R f05 f05R f1R f15R f1g25 f15g25 f1 f15 f2R f25R f2g25 f25g25 f2 f25 f3R f3g25 f3"

for SID in $SubjectID; do
	
	T1Dir="${DataDir}/${SID}/bet_fsl"
	TempDir="${T1Dir}/temp/${SID}_fmap_MeanMagnitude"
	Opts="brain.nii.gz --cmap copper --disabled"

	ParamLoad="Params$3"
	Overlays=""
	for i in ${!ParamLoad} ; do
    	Overlays="${Overlays} ${TempDir}_${i}_${Opts}"
	done

	fsleyes ${T1Dir}/${SID}_fmap_MeanMagnitude.nii.gz ${Overlays}
	
	clear

done

