#!/bin/bash

# Configuration file

# This file will set environments and variables which will be used throughout the preprocessing procedures.

#################################################################
#################################################################
#TODO: REMEMBER TO VERIFY IF THE IMAGES HAVE TO BE RESLICED!!!!!#
#################################################################
#################################################################

## Study variables

# Project name. This should be the name of the folder in which the study data is saved.
ProjectName="EyeMem"

## Set the base directory. This will be the place where we can access common files which are not particular to this project, for example, MNI images, gray matter masks and any shared toolboxes.

BaseDirectory="/home/mpib/LNDG"

## Set the working directory for the current project & it's script/data paths

WorkingDirectory="${BaseDirectory}/${ProjectName}"  		# Common project directory
DataPath="${WorkingDirectory}/BIDS/B2_data"	 						# Root Data
ScriptsPath="${WorkingDirectory}/study_information/A_scripts" 	# Pipe specific scripts
LogPath="${WorkingDirectory}/study_information/B_logs"			# Common log paths
SharedFilesPath_standards="${BaseDirectory}/Standards" 				# Toolboxes, Standards, etc
SharedFilesPath_toolboxes="${BaseDirectory}/toolboxes" 
ContainerPath="${WorkingDirectory}/study_information/C_toolboxes"

if [ ! -d ${LogPath} ]; then
	mkdir -p ${LogPath}
	chmod 770 ${LogPath}
fi

# Set subject ID list. Use an explicit list. No commas.
SubjectID="sub-35" #"sub-01 sub-02 sub-03 sub-04 sub-05 sub-06 sub-07 sub-08 sub-09 sub-10 sub-11 sub-12 sub-13 sub-14 sub-15 sub-16 sub-17 sub-18 sub-19 sub-20 sub-21 sub-22 sub-23 sub-24 sub-25 sub-26 sub-27 sub-28 sub-29 sub-30 sub-31 sub-32 sub-33 sub-34 sub-35 sub-36 sub-37 sub-38 sub-39 sub-40 sub-41 sub-42 sub-43 sub-44 sub-45 sub-46 sub-47 sub-48 sub-49 sub-50 sub-51 sub-52 sub-53 sub-54 sub-55 sub-56 sub-57 sub-58 sub-59 sub-60 sub-61 sub-62 sub-63 sub-64 sub-65 sub-66 sub-67 sub-68 sub-69 sub-70 sub-71 sub-72 sub-73 sub-74 sub-75 sub-76 sub-77 sub-78 sub-79 sub-80 sub-81 sub-82 sub-83 sub-84 sub-85 sub-86 sub-87 sub-88 sub-89 sub-90 sub-91 sub-92 sub-93 sub-94 sub-95 sub-96 sub-97 sub-98 sub-99 sub-100 sub-101"

# nr. of cpus for fmriprep
cpus="6"

# memory for fmriprep in GB
mem="10"

# Set task ID list (e.g. rest, eyemem). Task names must adhere to BIDS naming!
TaskID="rest"

# Name of experimental conditions, runs or task data to be analyzed. No commas.
RunID=""

# Voxel sizes & TR:
VoxelSize="3"
TR="1"

# FEAT standard variables
ToggleMCFLIRT="0"								# 0=No, 1=Yes: Default is 1
BETFunc="1" 									# 0=No, 1=Yes: Default is 1
TotalVolumes="600"
DeleteVolumes="12" 			
HighpassFEAT="0"			# 0=No, 1=Yes
SmoothingKernel="7"
RegisterStructDOF="BBR" 						# Default is BBR, other DOF options: 12, 9, 7, 6, 3
MNIImage="${SharedFilesPath_standards}/MNI152_T1_3mm_brain"

# Secondary FEAT variables (normally unused)
NonLinearReg="0"								# 0=No, 1=Yes: Default is 0
NonLinearWarp="10"								# Default is 10, applied only if NonLinearReg=1
IntensityNormalization="0" 						# 0=No, 1=Yes: Default is 0
SliceTimingCorrection="0"						# Default is 0; 0:None,1:Regular up,2:Regular down,3:Use slice order file,4:Use slice timings file,5:Interleaved

# Other FIELDmap variables
Unwarping="0"
UnwarpDir="-y"
EpiSpacing="0.28499967" # in ms
EpiTE="30" # in ms
SignalLossThresh="10"

# ICA variables
dimestVALUE="mdl" 								# Default is mdl
bgthresholdVALUE="3" 							# Default is 3
mmthreshVALUE="0.5" 							# Default is 0.5
dimensionalityVALUE="0" 						# Default is 0
AdditionalParameters="-v --Ostats" 				# Default are '-v --Ostats', verbose and, output thresholded maps and probability maps

# FIX
## Test Set for FIX
### Need to double check number of younger and old subjects
TestSetID="sub-11 sub-12 sub-18 sub-19 sub-26 sub-29 sub-34 sub-35 sub-38 sub-39 sub-40 sub-44 sub-46 sub-51 sub-56 sub-62 sub-66 sub-70 sub-73 sub-77 sub-85 sub-86 sub-88 sub-89 sub-90 sub-91 sub-97 sub-101"

## Accepted FIX Threshold
FixThreshold="40"

# Additional parameters
StandardsAndMasks="${ProjectName}_Standards" #For template
MeanValue="10000" #For re-adding mean