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
PreprocPipe="preproc2"

# Set subject ID list. Use an explicit list. No commas.
SubjectID="EYEMEM001 EYEMEM002 EYEMEM003 EYEMEM004 EYEMEM005 EYEMEM006 EYEMEM007 EYEMEM008 EYEMEM009 EYEMEM010 EYEMEM011 EYEMEM012 EYEMEM013 EYEMEM014 EYEMEM015 EYEMEM016 EYEMEM017 EYEMEM018 EYEMEM019 EYEMEM020 EYEMEM021 EYEMEM022 EYEMEM023 EYEMEM024 EYEMEM025 EYEMEM026 EYEMEM027 EYEMEM028 EYEMEM029 EYEMEM030 EYEMEM031 EYEMEM032 EYEMEM033 EYEMEM034 EYEMEM035 EYEMEM036 EYEMEM037 EYEMEM038 EYEMEM039 EYEMEM040 EYEMEM041 EYEMEM042 EYEMEM043 EYEMEM044 EYEMEM045 EYEMEM046 EYEMEM047 EYEMEM048 EYEMEM049 EYEMEM050 EYEMEM051 EYEMEM052 EYEMEM053 EYEMEM054 EYEMEM055 EYEMEM056 EYEMEM057 EYEMEM058 EYEMEM059 EYEMEM060 EYEMEM061 EYEMEM062 EYEMEM063 EYEMEM064 EYEMEM065 EYEMEM066 EYEMEM067 EYEMEM068 EYEMEM069 EYEMEM070 EYEMEM071 EYEMEM072 EYEMEM073 EYEMEM074 EYEMEM075 EYEMEM076 EYEMEM077 EYEMEM078 EYEMEM079 EYEMEM080 EYEMEM081 EYEMEM082 EYEMEM083 EYEMEM084 EYEMEM085 EYEMEM086 EYEMEM087 EYEMEM088 EYEMEM089 EYEMEM090 EYEMEM091 EYEMEM092 EYEMEM093 EYEMEM094 EYEMEM095 EYEMEM096 EYEMEM097 EYEMEM098 EYEMEM099 EYEMEM100 EYEMEM101"

# Set session ID list. Leave as an empty string if no sessions in data path.
SessionID=""

# Name of experimental conditions, runs or task data to be analyzed. No commas.
RunID="restingstate"

# Voxel sizes & TR:
VoxelSize="3"
TR="1"

# FEAT standard variables
TotalVolumes="474"
DeleteVolumes="12" 			
HighpassFEAT="0"			# 0=No, 1=Yes
HighpassThreshold="100"	
SmoothingFEAT="1"			# 0=No, 1=Yes
SmoothingKernel="7"

# Other FIELDmap variables
Unwarping="1"
UnwarpDir="-y"
EpiSpacing="0.285"
EpiTE="30"
SignalLossThresh="10"

# FIX
## Test Set for FIX
### Need to double check number of younger and old subjects
TestSetID="EYEMEM011 EYEMEM012 EYEMEM018 EYEMEM019 EYEMEM026 EYEMEM029 EYEMEM034 EYEMEM035 EYEMEM038 EYEMEM039 EYEMEM040 EYEMEM044 EYEMEM046 EYEMEM051 EYEMEM056 EYEMEM062 EYEMEM066 EYEMEM070 EYEMEM073 EYEMEM077 EYEMEM085 EYEMEM086 EYEMEM088 EYEMEM089 EYEMEM090 EYEMEM091 EYEMEM097 EYEMEM101"

## Accepted FIX Threshold
FixThreshold="40"

# Additional parameters
StandardsAndMasks="${ProjectName}_Standards" #For template
MeanValue="10000" #For re-adding mean

## Set the base directory. This will be the place where we can access common files which are not particular to this project, for example, MNI images, gray matter masks and any shared toolboxes.

CurrentDirectory=`pwd`
UserName=`whoami`

if [[ ${CurrentDirectory} == "/Volumes/LNDG/${UserName}"* ]]; then
	
	BaseDirectory="/Volumes/LNDG/${UserName}"
	
elif [[ ${CurrentDirectory} == "/Volumes/LNDG"* ]]; then
	
	BaseDirectory="/Volumes/LNDG"
	
elif [[ ${CurrentDirectory} == "/home/mpib/LNDG"* ]]; then
	
	BaseDirectory="/home/mpib/LNDG"
	
elif [[ ${CurrentDirectory} == "/home/mpib/${UserName}"* ]]; then
	
	BaseDirectory="/home/mpib/${UserName}"

elif [[ ${CurrentDirectory} == "/Users"* ]]; then
	
	BaseDirectory="Users/${UserName}"
	
fi

## Set the working directory for the current project & it's script/data paths
WorkingDirectory="${BaseDirectory}/${ProjectName}"  		# Common project directory
DataPath="${WorkingDirectory}/data_renamed"	 						# Root Data
ScriptsPath="${WorkingDirectory}/scripts/EyeMem_repo/${PreprocPipe}" 	# Pipe specific scripts
LogPath="${WorkingDirectory}/logs/${PreprocPipe}"			# Common log paths
SharedFilesPath="${WorkingDirectory}/scripts" 				# Toolboxes, Standards, etc

if [ ! -d ${LogPath} ]; then
	mkdir -p ${LogPath}
	chmod 770 ${LogPath}
fi