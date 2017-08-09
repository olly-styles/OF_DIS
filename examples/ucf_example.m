%% Example script for generating optical flow from video
addpath(genpath('../'));

VID_PATH = '/media/olly/BCEF-A9E3/UCF101/Archery/v_Archery_g01_c03.avi';

% Built in video OF traffic
traffic_vid = VideoReader(VID_PATH);

% Read video statistics
nframes = traffic_vid.NumberOFFrames;
vid_height = traffic_vid.Height;
vid_width = traffic_vid.Width;

% Create a 4d array to store video data
vid_array = zeros(vid_height,vid_width,3,nframes,'uint8');

% Create arrays to store horizontal and vertical optical flow data
OF_array_coarse = zeros(vid_height,vid_width,2,nframes-1,'single');
OF_array_fine = zeros(vid_height,vid_width,2,nframes-1,'single');

% Create arrays to store optical flow data in colour
color_OF_array_coarse = zeros(vid_height,vid_width,3,nframes-1,'uint8');
color_OF_array_fine = zeros(vid_height,vid_width,3,nframes-1,'uint8');

% Read the first frame
vid_array(:,:,:,1) = read(traffic_vid,1);

% Read the rest of the video
for i = 2 : nframes
    vid_array(:,:,:,i) = read(traffic_vid,i);
end

%% Estimate optical flow using coarsest scale and measure computation time
% flowToColor function defined in P. Dollars toolbox. The function
% flowToColor() is defined in it. Make sure you install it before running
% the command below. Otherwise you will get errors.

tic;
for i = 2 : nframes
    previous_frame_greyscale = rgb2gray(vid_array(:,:,:,i-1));
    current_frame_greyscale = rgb2gray(vid_array(:,:,:,i));
    OF_array_coarse(:,:,:,i) = run_OF_INT(current_frame_greyscale, previous_frame_greyscale, 2);
    color_OF_array_coarse(:,:,:,i) = flowToColor(OF_array_coarse(:,:,:,i));
end
toc;
%% Estimate optical flow using finest scale and measure computation time
% flowToColor function defined in P. Dollars toolbox. The function
% flowToColor() is defined in it. Make sure you install it before running
% the command below. Otherwise you will get errors.

tic;
for i = 2 : nframes
    previous_frame_greyscale = rgb2gray(vid_array(:,:,:,i-1));
    current_frame_greyscale = rgb2gray(vid_array(:,:,:,i));
    OF_array_fine(:,:,:,i) = run_OF_INT(previous_frame_greyscale, current_frame_greyscale, 4);
    color_OF_array_fine(:,:,:,i) = flowToColor(OF_array_fine(:,:,:,i));
end
toc;
%% Concatenate coarse and fine optical flow results with original and play video
OF_comparison_array = horzcat(color_OF_array_coarse,color_OF_array_fine,vid_array);
implay(OF_comparison_array)
%%
f1 = rgb2gray(vid_array(:,:,:,5));
f2 = rgb2gray(vid_array(:,:,:,6));
flow1 = flowToColor(run_OF_INT(f1,f2,1));
flow2 = flowToColor(run_OF_INT(f1,f2,2));
flow3 = flowToColor(run_OF_INT(f1,f2,3));
flow4 = flowToColor(run_OF_INT(f1,f2,4));
%%
subplot(1,5,5); imshow(f1); title('Original', 'FontSize',20);
subplot(1,5,4); imshow(flow1); title('Flow 1 (Online)', 'FontSize',20);
subplot(1,5,3); imshow(flow2); title('Flow 2 (Online)', 'FontSize',20);
subplot(1,5,2); imshow(flow3); title('Flow 3 (Offline)', 'FontSize',20);
subplot(1,5,1); imshow(flow4); title('Flow 4 (Offline)', 'FontSize',20);

%% Frame 5 comparison
subplot(2,3,1); imshow(vid_array(:,:,:,5)); title('Original frame 1','FontSize',20);
subplot(2,3,4); imshow(vid_array(:,:,:,6)); title('Original frame 2','FontSize',20);
subplot(2,3,2); imshow(OF_array_coarse(:,:,1,5),[]); title('Online optical flow, x axis','FontSize',20);
subplot(2,3,3); imshow(OF_array_fine(:,:,1,5),[]); title('Offline optical flow, x axis','FontSize',20); 
subplot(2,3,5); imshow(OF_array_coarse(:,:,2,5),[]); title('Online optical flow, y axis','FontSize',20);
subplot(2,3,6); imshow(OF_array_fine(:,:,2,5),[]); title('Offline optical flow, y axis','FontSize',20);

%%
frame = OF_array_coarse(:,:,1,5);
scaled = scale_image(frame,0,255);

%%
scaled_int = uint8(scaled);
%%
whos scaled_int
imwrite(uint8(scaled),'test.jpg','jpg')
%%
jpg = imread('test.jpg');
whos frame
whos scaled_int
%%
subplot(2,1,1); imshow(frame,[]); title('Original');
subplot(2,1,2); imshow(jpg,[]); title('JPG');
%%
implay(OF_array_coarse(:,:,1,:))
%%
image = OF_array_coarse(:,:,1,:);
handle = implay(image);

handle.Visual.ColorMap.UserRange = 1; handle.Visual.ColorMap.UserRangeMin = min(image(:)); handle.Visual.ColorMap.UserRangeMax = max(image(:));
%%
vid = zeros(vid_height,vid_width,1,nframes,'uint8');
for i = 1:nframes
    vid(:,:,1,i) = uint8(scale_image(OF_array_coarse(:,:,1,i),0,255));
end
%%
v = VideoWriter('newfile','Motion JPEG 2000');
open(v)
writeVideo(v,vid);
close(v)
%%
v = VideoReader('newfile.mj2')

% Read video statistics
nframes = v.NumberOFFrames;
vid_height = v.Height;
vid_width = v.Width;

% Create a 4d array to store video data
vid_array = zeros(vid_height,vid_width,1,nframes,'uint8');

% Read the first frame
vid_array(:,:,:,1) = read(v,1);

% Read the rest OF the video
for i = 2 : nframes
    vid_array(:,:,:,i) = read(v,i);
end