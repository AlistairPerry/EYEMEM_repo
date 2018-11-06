#!/bin/bash

## Make log folders

source preproc_config.sh

mkdir ${LogPath}/BET
mkdir ${LogPath}/FEAT
mkdir ${LogPath}/Detrend_Filt
mkdir ${LogPath}/ICA
mkdir ${LogPath}/Denoise
mkdir ${LogPath}/FLIRT
mkdir ${LogPath}/prepareFM
mkdir ${LogPath}/BET_QC


mkdir ${ScriptsPath}/05_FIX/rejcomps
mkdir ${LogPath}/FIX/Extract_Features
mkdir ${LogPath}/FIX/Log_Matlab
mkdir ${LogPath}/FIX/Create_Hand_Labels_Noise
mkdir ${LogPath}/FIX/Create_Training_Data
mkdir ${LogPath}/FIX/Apply_Threshold