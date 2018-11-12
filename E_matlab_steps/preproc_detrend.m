function preproc_detrend(Input, Output, PolyOrder, MaskPath)
% This function takes a nifti file, without the name of the extensions, as
% the input.

%% For compiled version

% Use the following:
% /opt/matlab/R2014b/bin/mcc -m detrend -a /home/mpib/LNDG/toolboxes/NIfTI_20140122 -a /home/mpib/LNDG/toolboxes/preprocessing_tools

%% Initialize

PreprocDataPath = [ Input, '.nii.gz'];

% Verify if data exists

if ~exist (PreprocDataPath,'file');
    disp([ PreprocDataPath, ' not found. Aborting detrend...' ])
    return;
end

if ~exist( 'Output', 'var' ) || isempty(Output);
    Output = ( Input );
end

%% Set kth order polynomial.

if ~exist( 'PolyOrder', 'var' );
    PolyOrder = 3;                                                          %  2nd order: linear and quadratic detrending.
elseif ischar(PolyOrder) && ~isempty(str2num(PolyOrder)) 
    PolyOrder=str2num(PolyOrder);
else
    PolyOrder = 3;    
end

%% Load NIfTI

disp ([ PreprocDataPath ': will be detrended' ])
try
    img = load_untouch_nii ( [PreprocDataPath] );                                                  % Original data, including header information necessary for saving a NIfTI file
catch ME
    disp (ME)
    disp([PreprocDataPath ' did NOT want to load!' ])
end
nii = double(reshape( img.img, [], img.hdr.dime.dim(5) ));                  % Image file which will be detrended

%% load mask

mask = load_untouch_nii (MaskPath);
mask = double(reshape(mask.img, [], mask.hdr.dime.dim(5)));
mask_coords = find(mask);

% mask & mean image
nii_masked = nii(mask_coords,:);
nii_means = mean(nii_masked,2);

%% Detrend & prepare image file

% Transpose matrix: now colums is time and row is voxel
data = nii_masked';

% detrend in serveral steps. 1. linear 2. quadratic 3. cubic 4. quartic

disp ([ 'Detrending ' PreprocDataPath ' using PolyOrder ' num2str(PolyOrder) ] )
for i=1:PolyOrder
    data = spm_detrend(data,i);
end

%retranspose matrix
nii_masked = data';

%% Read TS voxel means
for i=1:size(nii_masked,2)
    nii_masked(:,i) = nii_masked(:,i)+nii_means;
end

nii(mask_coords,:)= nii_masked;
img.img = nii;                                                              % Replaces previous nifti image with detrended image within the nifti data structure

%% Save detrended nifti

save_untouch_nii (img, [ Output, '_detrended.nii.gz' ]);
disp ([ Output, '_detrended.nii.gz created: detrending done' ])

clear Data nii_masked img data mask nii mask_coords nii_means

end