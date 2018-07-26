#!/bin/bash


#### From HCP Pipeline ###

${FSLDIR}/bin/fslmaths ${MagnitudeInputName} -Tmean ${WD}/Magnitude

### They say BET, I'm going to use ANTs bra

#${FSLDIR}/bin/bet ${WD}/Magnitude ${WD}/Magnitude_brain -f 0.35 -m #Brain extract the magnitude image



${FSLDIR}/bin/imcp ${PhaseInputName} ${WD}/Phase
${FSLDIR}/bin/fsl_prepare_fieldmap SIEMENS ${WD}/Phase ${WD}/Magnitude_brain   2.46
