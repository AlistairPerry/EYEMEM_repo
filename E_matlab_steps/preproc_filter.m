function preproc_filter(Input, TR, HighpassFilterLowCutoff, LowpassFilterHighCutoff, FilterOrder, Output, MaskPath)
% Usage: bandpass(Input, Output, TR, LowCutoff, HighCutoff, FilterOrder)
% Mandatory parameters: bandpass(Input, [], TR, [], [], [])
%
% This function takes a nifti file, without the name of the extensions, as
% the first input.  As a second input, it can accept another location as an
% output location, otherwise it will assume that you want to save the
% bandpassed image in the same location and with the same name as your
% first input. As a third input it requires the sampling rate (TR). As a
% fourth input it can accept a low cutoff filter, which is set to 0.01 by
% default. As a fifth input it can accept a high cutoff filter, which is 
% set to 0.1 by default. As a sixth input it can accept a filter order, which
% is set to 8 by default.

%% For compiled version

% Use the following:
% /opt/matlab/R2014b/bin/mcc -m bandpass -a /home/mpib/LNDG/toolboxes/NIfTI_20140122

%% Initialize

if exist([ Input, '.nii.gz' ]); 
    PreprocDataPath = [ Input, '.nii.gz' ];
else
    PreprocDataPath = [ Input ];
end

% Verify if data exists and if output location was specified 

if ~exist ( PreprocDataPath, 'file' );
    disp([ PreprocDataPath, ' not found. Aborting bandpass...' ])
    return;
end

if ~exist( 'Output', 'var' ) || isempty(Output);
    Output = ( Input );
end

%% Set Parameters

% Verify if paremters were specified by the user and set them to default
% values if they weren't

% Hgihpass cutoff value
if ~exist( 'HighpassFilterLowCutoff', 'var' );
    HighpassFilterLowCutoff = 0.01;
elseif ischar(HighpassFilterLowCutoff) && ~isempty(str2num(HighpassFilterLowCutoff)) 
    HighpassFilterLowCutoff=str2num(HighpassFilterLowCutoff);
elseif strcmp(HighpassFilterLowCutoff,'off')
	disp ([ 'Highpass has been turned off.' ])
else
    disp ([ 'HighpassFilterLowCutoff incorrect input.'])  
end

% Lowpass cutoff value
if ~exist( 'LowpassFilterHighCutoff', 'var' );
    LowpassFilterHighCutoff = 0.1;
elseif ischar(LowpassFilterHighCutoff) && ~isempty(str2num(LowpassFilterHighCutoff)) 
    LowpassFilterHighCutoff=str2num(LowpassFilterHighCutoff);
elseif strcmp(LowpassFilterHighCutoff,'off')
	disp ([ 'Lowpass has been turned off.' ])
else 
    disp ([ 'LowpassFilterHighCutoff incorrect input.']) 
end

% Output Stage

if ~strcmp(HighpassFilterLowCutoff,'off') && ~strcmp(LowpassFilterHighCutoff,'off')
    OutputStage='bandpassed'
elseif ~strcmp(HighpassFilterLowCutoff,'off') && strcmp(LowpassFilterHighCutoff,'off')
    OutputStage='highpassed'
elseif strcmp(HighpassFilterLowCutoff,'off') && ~strcmp(LowpassFilterHighCutoff,'off')
    OutputStage='lowpassed'  
end
        
% Filter order
if ~exist( 'FilterOrder', 'var' );
    FilterOrder = 8;
elseif ischar(FilterOrder) && ~isempty(str2num(FilterOrder)) 
    FilterOrder=str2num(FilterOrder);
else
    FilterOrder = 8;
end

% TR
if ~exist( 'TR', 'var' );
    disp([ 'TR not found. Not filtering...' ])
    return;
elseif ischar(TR) && isnumeric(str2num(TR)) 
    TR=str2num(TR);
else 
    disp([ TR 'not a valid input for TR. Not filtering...' ])
    return;
end

% Sampling Rate in Hz
SamplingRate = 1/TR;        

%% Load NIfTI

disp ([ 'Loading ' PreprocDataPath ])
try
    img = load_untouch_nii ( [PreprocDataPath] );                           % Original data, including header information necessary for saving a NIfTI file
catch ME
    disp (ME)
    disp([PreprocDataPath ' did NOT want to load!' ])
end
disp ([ PreprocDataPath ' will be ' OutputStage ])
disp(['Filter Order: ' num2str(FilterOrder)])
disp(['Using Highpass: ' num2str(HighpassFilterLowCutoff)])
disp(['Using Lowpass: ' num2str(LowpassFilterHighCutoff)])

nii = double( reshape(img.img, [], img.hdr.dime.dim(5)) );                  % Original data, to be bandpass filtered

%% load mask

mask = load_untouch_nii (MaskPath);
mask = double(reshape(mask.img, [], mask.hdr.dime.dim(5)));
mask_coords = find(mask);

% mask & mean image
nii_masked = nii(mask_coords,:);
nii_means = mean(nii_masked,2);

%% Butterworth filters

for i = 1:size(nii_masked,1)

    % Highpass filter
    if ~strcmp(HighpassFilterLowCutoff,'off')
        [B,A] = butter(FilterOrder,HighpassFilterLowCutoff/(SamplingRate/2),'high'); 
        nii_masked(i,:)  = filtfilt(B,A,nii_masked(i,:)); clear A B;
    end
    
    % Lowpass filter
    if ~strcmp(LowpassFilterHighCutoff,'off')   
        [B,A] = butter(FilterOrder,LowpassFilterHighCutoff/(SamplingRate/2),'low');
        nii_masked(i,:)  = filtfilt(B,A,nii_masked(i,:)); clear A B
    end
    
end

%% Read TS voxel means

for i=1:size(nii_masked,2)
    nii_masked(:,i) = nii_masked(:,i)+nii_means;
end

% Prepare image file

nii(mask_coords,:)= nii_masked;
img.img = nii;                                                              % Replaces original image with bandpass filtered image within the nifti data structure

%% Save filtered nifti

save_untouch_nii (img, [ Output , '_' OutputStage '.nii.gz']);
disp ([ Output , '_' OutputStage '.nii.gz created: filtering done.'])

clear Input Output Data 

end