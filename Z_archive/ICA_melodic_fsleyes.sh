#!/bin/bash

# This script loop through subjects and condtions of a certain preprocessed fMRI dataset, opening FSL MELODICS IC threshold maps with an T1 underlay. 

# Arguments:
#  		ICA_eval_fslview.sh  Workingdir Subjects Conditions Threshold
#		1. Workingdir:			string
#		2. Subjects: 			string
#		3. Conditions:			string (optional)
#		4. Inital threshold:	int (optional); default for single component viewer = 0.5, default for melodic perspective: min = 2, max = 15 (input as '2 15')
#		5. FSLview mode:		string (experimental)
#								Initial viewer mode. Comma separated list of: 3d; single, ortho; lightbox
#
# Example: ICA_eval_fslview.sh /User/Desktop/data/  'subj1 subj2' 'run1 run2' 

clear

printf 'Would you like to use Melodic Perspective?\ny/n?\nConfirm with eneter:\n' 
read -r input0

if [ $input0 == 'y' ] || [ $input0 == 'Y' ]; then
	clear

	printf 'This will load a subjects melodic directory and the anat2func background image\nThis mode can be used to name and select noise components\nProceed with enter\n'
	read -r input1

	clear

	printf '\n ------------------------------------------ \n\nto close the application press control+c \n\n'
	printf 'to skip a run/condition/component close fslview \n\n'
	if (( $# == 4 )); then
		newCount=0
		for threshVar in $4; do
			newCount=$((newCount + 1))
			if [ $newCount = '1' ]; then
				minDISP=$threshVar
			elif [ $newCount = '2' ]; then
				maxDISP=$threshVar
			fi
		done
	fi
	
	if (( $# < 2 )); then
	    echo "illegal number of parameters"
		exit
	elif (( $# < 3 )); then
		echo "no conditions/runs set"
		exit
	elif (( $# < 4 )); then
	 	WD=$1
		SUBJECTS=$2
		CONDITIONS=$3
		minDISP='2'
		maxDISP='15'
		echo "display reange set to min = 2, max = 15"
	elif (( $# < 5 )) && [ $newCount = '1' ] ; then
	 	WD=$1
		SUBJECTS=$2
		CONDITIONS=$3
		maxDISP='15'
		echo "display range set to min = $minDISP, max = 15"
	elif (( $# < 5 )) && [ ! $newCount = '1' ]; then
	 	WD=$1
		SUBJECTS=$2
		CONDITIONS=$3
		echo "display thresholds set to min = $minDISP, max = $maxDISP"
	fi

	# Check if paths are valid
	if [ ! -d  "$WD" ]; then
		echo "$WD not valid"
		exit
	else
		echo "you are in $WD"
		echo "working on subjects: $SUBJECTS"
		echo "with conditions/runs: $CONDITIONS"
		printf '\n\n'
		cd $WD
	fi

	# subject loop
	for subj in ${SUBJECTS[@]} ; do

		echo $subj

		# subject loop
		for cond in ${CONDITIONS[@]} ; do

			echo $cond

			##########################################################
			# ADJUST THIS SECTION IF NECESSARY
			##########################################################
			subjDIR="${WD}/${subj}/"
			icDIR="${subjDIR}/FEAT.feat/filtered_func_data.ica"
			anatFILE="${subjDIR}/anat2func.nii.gz"
			##########################################################		
		
			# Check if paths are valid
			if [ ! -d  "$icDIR" ]; then
				echo "$icDIR not valid, maybe subject or condition not availible"
				continue
			fi

			if [ ! -f  "$anatFILE" ]; then
				echo "$anatFILE not valid"
				continue
			fi
		
			fsleyes -s melodic ${anatFILE} ${icDIR} --useNegativeCmap --displayRange ${minDISP} ${maxDISP} --clippingRange ${minDISP} ${maxDISP} --cmap red-yellow --negativeCmap blue-lightblue 
			
		done # condtions
		clear
	done #subjects
else
printf 'Press Y if you want to load all subjects IC maps at once \nPress N if you want to load single IC maps seperatly\nConfirm with enter\n' ALLsubj
read -r input1

#clear

if [ ! $input1 = "Y" ] || [ ! $input1 = "y" ]; then
	printf 'Press Y if you only want to load ONE component \n' 
	read -r input2
	
	#clear
	
	if [ $input2 = "Y" ] || [ $input2 = "y" ]; then
		printf 'NOTE: If you have given multiple subject or run inputs,\nNOTE: then this will only load the desired component for the FIRST subject/run pairing\n\n'
		printf 'Which component do you want to load?\n' 
		read -r component
		
		#clear
	fi
fi

printf '\n ------------------------------------------ \n\nto close the application press control+c \n\n'
printf 'to skip a run/condition/component close fslview \n\n'
printf ' ------------------------------------------ \n\nadjust the threshold level of the Z values in FSLview brightness scaler\n\n ------------------------------------------ \n\n' 


if (( $# < 2 )); then
    echo "illegal number of parameters"
	exit

elif (( $# < 3 )); then
 	WD=$1
	SUBJECTS=$2
	CONDITIONS=''
	echo "no conditions/runs set"

elif (( $# < 4 )); then
	 
 	WD=$1
	SUBJECTS=$2
	CONDITIONS=$3
	THR=0.5
	printf "set inital Z threshold to 0.5\n\n"
	
elif (( $# < 5 )); then
	WD=$1
	SUBJECTS=$2
	CONDITIONS=$3
	THR=$4
	MODE=''
	printf "set inital Z threshold to ${THR}\n\n"
else
	WD=$1
	SUBJECTS=$2
	CONDITIONS=$3
	THR=$4
	MODE=$5
	printf "set inital Z threshold to ${THR}\n\n"
	printf "Mode is $5"
fi

#WD='/Volumes/FB-LIP/EyeMem/data_renamed/'
#SUBJECTS='EYEMEM066'
#CONDITIONS='fractals landscapes naturals1 restingstate streets1 streets2'
#CONDITIONS='fractals'



# Check if paths are valid
if [ ! -d  "$WD" ]; then
	echo "$WD not valid"
	exit
else
	echo "you are in $WD"
	echo "working on subjects: $SUBJECTS"
	echo "with conditions/runs: $CONDITIONS"
	printf '\n\n'
	cd $WD
fi

# subject loop
for subj in ${SUBJECTS[@]} ; do

	echo $subj

	# subject loop
	for cond in ${CONDITIONS[@]} ; do

		echo $cond

		##########################################################
		# ADJUST THIS SECTION IF NECESSARY
		##########################################################
		subjDIR="${WD}/${subj}/preproc/${cond}/"
		icDIR="${subjDIR}/FEAT.feat/filtered_func_data.ica/stats/"
		anatDIR="${subjDIR}/"
		##########################################################		
		
		
		# Check if paths are valid
		if [ ! -d  "$icDIR" ]; then
			echo "$icDIR not valid, maybe subject or condition not availible"
			continue
		fi

		if [ ! -d  "$anatDIR" ]; then
			echo "$anatDIR not valid"
			continue
		fi

		#number of ICs
		echo ${icDIR}
		ICcount=$(ls -1 ${icDIR}thresh_zstat* | wc -l)
		
		printf "condition/run $cond of subject ${subj} has ${ICcount} ICs \n" | xargs
		
		
		#load all subjects IC maps at once or single IC maps one after another (Optionally: load ONE component)
		
			
		if [ $input1 = 'N' ] || [ $input1 = 'n' ]; then
			if [ $input2 = "Y" ] || [ $input2 = "y" ]; then
				ICcount=1
			fi
			input3="Y"
			while [ $input3 = "Y" ]; do
				
				for ((ic=1; ic<=$ICcount; ic++)) ; do
					if [ $input2 = "Y" ] || [ $input2 = "y" ]; then
						ic=$component
					fi
            	
					##########################################################
					# ADJUST THIS SECTION IF NECESSARY
					##########################################################	
					icFILE="${icDIR}/probmap_${ic}.nii.gz"
					anatFILE="${anatDIR}/anat2func.nii.gz"
					##########################################################
            		
            		
					# Check if files are valid
					if [ ! -e  "$icFILE" ]; then
						echo "$icFILE not valid"
						exit
					else printf "now: ${icFILE}\n"
					fi
            		
					if [ ! -e  "$anatFILE" ]; then
						echo "$anatFILE not valid"
						exit
					fi
	        											
					# open fsleyes
					if [ ! -z "$MODE" ]; then  		
						fsleyes ${anatFILE} -m ${MODE} ${icFILE} -cm Red-Yellow -dr ${THR} 2
					else 
						fsleyes ${anatFILE} ${icFILE} -cm Red-Yellow -dr ${THR} 2
					fi
						
					printf 'done\n' 
		    		clear
					
				done #ICs
				# Ask for a new component if loading individually
				if [ $input2 = "Y" ] || [ $input2 = "y" ]; then 
					printf "Press Y if you want to load another component for ${subj} ${cond}\nPress N if you are finished with ${subj} ${cond}\n"
					read -r input3
					clear
					if [ $input3 = "Y" ] || [ $input3 = "y" ]; then
						printf 'NOTE: If you have given multiple subject or run inputs,\nNOTE: then this will only load the desired component for the FIRST subject/run pairing\n\n'
						printf 'Which component do you want to load?\n' 
						read -r component
					fi
				fi
				# End while loop if loading every component in a row
				if (( $ICcount > 1 )); then
					input3="N"
					clear
				fi
			done
		else 
			
			##########################################################
			# ADJUST THIS SECTION IF NECESSARY
			##########################################################	
			anatFILE="${anatDIR}/anat2func.nii.gz"
			##########################################################
			
			if [ ! -e  "$anatFILE" ]; then
				echo "$anatFILE not valid"
				exit
			fi
			
			ICfiles=''
			for ((ic=1; ic<=$ICcount; ic++)) ; do
				##########################################################
				# ADJUST THIS SECTION IF NECESSARY
				##########################################################		
				icFILE="${icDIR}/probmap_${ic}.nii.gz"		
				##########################################################

				# Check if files are valid
				if [ ! -e  "$icFILE" ]; then
					echo "INVALID: $icFILE"
					exit
				else 
					ICfiles="${ICfiles} ${icFILE} -cm Red-Yellow -dr ${THR} 2"
				fi

			done #allICs
			
			printf "loading:\n${anatFILE} ${ICfiles}\n"
			
			# open fsleyes

			if [ ! -z "$MODE" ]; then  		
				echo fsleyes ${anatFILE} -m ${MODE} ${ICfiles}
				fsleyes ${anatFILE} -m ${MODE} ${ICfiles} 
			else 
				fsleyes ${anatFILE} ${ICfiles} 
			fi
			
			printf 'done\n\n' 
		fi
			
	done # condtions
	clear
done #subjects
fi
