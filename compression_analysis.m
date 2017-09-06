%% Analysis of data loss incurred by rescaling flow and saving as mj2
addpath(genpath('../'));
OF_FILEPATH = '/media/olly/olly64gb/of_data/coarse2/of/v_ApplyEyeMakeup_g01_c01.avi_coarse_OF.mj2';
SCALE_FILEPATH = '/media/olly/olly64gb/of_data/coarse2/scale_data/ApplyEyeMakeup_g25_c07_coarse_of_scale_data.mat';
VID_FILEPATH = '/home/olly/cs/summer_2017/UCF101/ApplyEyeMakeup/v_ApplyEyeMakeup_g01_c01.avi';

% Load optical flow from file
compressed_flow = vid_to_array(OF_FILEPATH,false);

% Create a 3d array to store scaled flow data
scaled_flow = zeros(size(compressed_flow),'single');

% Load scale data
load(SCALE_FILEPATH);

% For every frame, scale OF to original range
for i = 1 : size(compressed_flow,3)
    frame = single(compressed_flow(:,:,i));
    new_min = single(scale_data{1,2}(i));
    new_max = single(scale_data{1,3}(i));
    scaled_flow(:,:,i) = scale_optical_flow(frame,new_min,new_max,0,255);
end
% scaled_flow is now the reconstructed optical flow

%% Generate original optical flow for comparison
% Load original and get info
vid = vid_to_array(VID_FILEPATH,true);
vid_height = size(vid,1);
vid_width = size(vid,2);
nframes = size(vid,4);

original_scaled_flow = zeros(vid_height,vid_width,2,nframes-1,'single');

% Compute optical flow
for i = 2 : size(vid,4)
    previous_frame_greyscale = rgb2gray(vid(:,:,:,i-1));
    current_frame_greyscale = rgb2gray(vid(:,:,:,i));
    original_scaled_flow(:,:,:,i) = run_OF_INT(current_frame_greyscale, previous_frame_greyscale, 2);
end

% Clip vectors with magnitude > 20
original_scaled_flow(original_scaled_flow < -20) = -20;
original_scaled_flow(original_scaled_flow > 20) = 20;
original_scaled_flow = reshape(original_scaled_flow,[size(scaled_flow)]);

% original_scaled_flow is now the original optical flow before compression
%% Find error statistics
total_error = abs(original_scaled_flow - scaled_flow);
frame_errors = mean(mean(abs(total_error./original_scaled_flow)));
overall_error = mean(frame_errors(3:end))

%% Plot an example frame of original vs resonstructed flow in colour
reconstructed = reshape(scaled_flow,[240,320,2,165]);
original = reshape(original_scaled_flow,[240,320,2,165]);
subplot(1,2,1); imshow(flowToColor(reconstructed(:,:,:,120))); title('reconstructed');
subplot(1,2,2); imshow(flowToColor(original(:,:,:,120))); title('original');
