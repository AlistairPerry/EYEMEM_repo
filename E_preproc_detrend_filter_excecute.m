function C_preproc_detrend_filter_excecute(FuncPath, FuncImage, PolyOrder, TR, HighpassFilterLowCutoff, LowpassFilterHighCutoff, FilterOrder)
%% For compilation:

% source preproc2_config.sh; /opt/matlab/R2017b/bin/mcc -m E_preproc_detrend_filter_excecute -a ${SharedFilesPath_toolboxes}/NIfTI_20140122 -a ${SharedFilesPath_toolboxes}/spm_detrend -a ${ScriptsPath}/E_matlab_steps

disp (['Will attempt to process ' FuncImage ])

cd ([ FuncPath ]);
if ~exist([ FuncImage, '_detrended.nii.gz' ], 'file')
    preproc_detrend( [ FuncPath, '/FEAT.feat/filtered_func_data' ], [FuncPath '/' FuncImage] , PolyOrder, [FuncPath '/FEAT.feat/mask.nii.gz'] ); 
end

cd ([ FuncPath ]);
if ~exist([ FuncImage, '_detrended_bandpassed.nii.gz' ], 'file') || ~exist([ FuncImage, '_detrended_lowpassed.nii.gz' ], 'file')... 
        || ~exist([ FuncImage, '_detrended_highpassed.nii.gz' ], 'file') && exist([ FuncImage, '_detrended.nii.gz' ], 'file')
    preproc_filter ( [ FuncImage, '_detrended' ], TR, num2str(HighpassFilterLowCutoff), num2str(LowpassFilterHighCutoff), FilterOrder, [], [FuncPath '/FEAT.feat/mask.nii.gz']);
end

end
