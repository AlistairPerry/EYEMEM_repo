function B_GMcommonCoords
%This script creates a mask of coordinates including only gray matter (GM) coordinates and
%commonly activated coordinates for all subjects in the sample called final coordinates
%        
%Note: All niftis need to have the same resolution and be in standard space
%Input: preprocessed functional niftis in standard space
%Output: mat file containing common coordinates

%% NOTE ABOUT MASK USED FOR ANALYSIS 

% A mask containing a total of N115 subjects was used in the analysis, but 
% said analysis only contained a total of N100 subjects. This is due to 
% the fact that, for this study, we were only interested in adult brains 
% and 15 of the N115 subjects were children, which were later dropped from 
% analysis. For this reason, we are including the original coordinates of 
% the N115 mask in the following location in the repository:
% 
% ./NKI_enhanced_rest/G_standards_masks/GM_mask/N115_GMcommoncoords.mat

%% Specify paths

ProjectPath = '/home/mpib/LNDG'

SubjectList = {'sub-01' 'sub-02' 'sub-03' 'sub-04' 'sub-05' 'sub-06' 'sub-07' 'sub-08' 'sub-09' 'sub-10' 'sub-100' 'sub-101' 'sub-11' 'sub-12' 'sub-13' 'sub-14' 'sub-15' 'sub-16' 'sub-17' 'sub-18' 'sub-19' 'sub-20' 'sub-21' 'sub-22' 'sub-23' 'sub-24' 'sub-25' 'sub-26' 'sub-27' 'sub-28' 'sub-29' 'sub-30' 'sub-31' 'sub-32' 'sub-33' 'sub-34' 'sub-35' 'sub-36' 'sub-37' 'sub-38' 'sub-39' 'sub-40' 'sub-41' 'sub-42' 'sub-43' 'sub-44' 'sub-45' 'sub-46' 'sub-47' 'sub-48' 'sub-49' 'sub-50' 'sub-51' 'sub-52' 'sub-53' 'sub-54' 'sub-55' 'sub-56' 'sub-57' 'sub-58' 'sub-59' 'sub-60' 'sub-61' 'sub-62' 'sub-63' 'sub-64' 'sub-65' 'sub-66' 'sub-67' 'sub-68' 'sub-69' 'sub-70' 'sub-71' 'sub-72' 'sub-73' 'sub-74' 'sub-75' 'sub-76' 'sub-77' 'sub-78' 'sub-79' 'sub-80' 'sub-81' 'sub-82' 'sub-83' 'sub-84' 'sub-85' 'sub-86' 'sub-87' 'sub-88' 'sub-89' 'sub-90' 'sub-91' 'sub-92' 'sub-93' 'sub-94' 'sub-95' 'sub-96' 'sub-97' 'sub-98' 'sub-99'}

DATAPATH = [ProjectPath, 'A_preproc/data/']; %preprocessed niftis in standard space

SAVEPATH = [ProjectPath, 'G_standards_masks/GM_mask']; %standard gray matter mask

%% Load MNI template of GM mask

GMmask=load_nii ([ProjectPath, 'G_standards_masks/avg152_T1_gray_mask_90.nii']);

final_coords = (find(GMmask.img))';

%% Get common coordinates
% initialize common coordinates to a vector from 1 to 1 million to ensure 1st subjects coords are all included

common_coords = (1:1000000);


for i = 1:numel(SubjectList)
   try
    
    % load subject nifti
    fname = [DATAPATH , SubjectList{i}, '/rest/', SubjectList{i}, '_rest_feat_BPfilt_denoised_MNI2mm_flirt_detrended.nii'];

    nii = load_nii(fname); %load preprocessed images
    
        
    % create a matrix of intersecting coordinats over all subjects
    subj_coords = find(nii.img(:,:,:,1));
    common_coords=intersect(common_coords,subj_coords);
  
    disp ([SubjectList{i}, ': added to common coords'])
  
   % Error log    
   catch ME
       warning(['error with subject ', SubjectList{i}]);
   end
   
end

%% Match common coordinates with GM coordinates

final_coords=intersect(final_coords,common_coords); % creates final coordinates
final_coords=final_coords';

%% Save final coordinates

save ([SAVEPATH, 'GMcommoncoords.mat'], 'final_coords');

end

