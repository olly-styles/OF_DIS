%% Extract optical flow from UCF dataset store as JPEG
addpath(genpath('../'));
DATASET_PATH = '/media/olly/BCEF-A9E3/UCF101/';
SAVE_PATH = '/media/olly/BCEF-A9E3/of_data/';

d = dir(DATASET_PATH);
% Taken from https://tinyurl.com/y8szqdoa
isub = [d(:).isdir]; % logical vector
dir_names = {d(isub).name}'; % Directory names
dir_names(ismember(dir_names,{'.','..'})) = []; % Remove . and ..
dir_names = dir_names(18:end);
for directory = dir_names'
    % Get complete path to dataset directory
    complete_path = strcat(DATASET_PATH,directory,'/');
    complete_path = complete_path{1}
    files = dir(strcat(complete_path,'/*.avi')); % All files
    filenum = 1;
    scale_data = cell(length(files),3);
    for file = files'
        % Read video
        name = file.name
        
        vid = VideoReader([complete_path name]);
        
        % Read video statistics
        nframes = vid.NumberOFFrames;
        vid_height = vid.Height;
        vid_width = vid.Width;

        % Create a 4d array to store video data
        vid_array = zeros(vid_height,vid_width,3,nframes,'uint8');
        
        % Create array to store horizontal and vertical optical flow data
        OF_array = zeros(vid_height,vid_width,2,nframes-1,'single');
        
        % Read the first frame
        vid_array(:,:,:,1) = read(vid,1);

        % Read the rest of the video
        for i = 2 : nframes
            vid_array(:,:,:,i) = read(vid,i);
        end
        
        % Extract OF
        for i = 2 : nframes
            previous_frame_greyscale = rgb2gray(vid_array(:,:,:,i-1));
            current_frame_greyscale = rgb2gray(vid_array(:,:,:,i));
            OF_array(:,:,:,i) = run_OF_INT(current_frame_greyscale, previous_frame_greyscale, 2);
        end
        
        % Clip vectors with magnitude > 20
        OF_array(OF_array < -20) = -20;
        OF_array(OF_array > 20) = 20;
        
        vid_mins = zeros(1,nframes*2,'single');
        vid_maxes = zeros(1,nframes*2,'single');

        % Scale optical flow to range [0 255]
        OF_scaled = zeros(vid_height,vid_width,1,nframes*2,'uint8');
        
        for i = 0:nframes-1
            frame_min = min(min(OF_array(:,:,1,i+1)));
            frame_max = max(max(OF_array(:,:,1,i+1)));
            OF_scaled(:,:,1,(2*i)+1) = uint8(scale_optical_flow(...
                           OF_array(:,:,1,i+1),0,255,frame_min,frame_max));
            vid_mins(2*i+1) = frame_min;
            vid_maxes(2*i+1) = frame_max;

            frame_min = min(min(OF_array(:,:,2,i+1)));
            frame_max = max(max(OF_array(:,:,2,i+1)));
            OF_scaled(:,:,1,(2*i)+2) = uint8(scale_optical_flow(...
                           OF_array(:,:,2,i+1),0,255,frame_min,frame_max));
            vid_mins(2*i+2) = frame_min;
            vid_maxes(2*i+2) = frame_max;

        end
        
        scale_data{filenum,1} = name;
        scale_data{filenum,2} = vid_mins;
        scale_data{filenum,3} = vid_maxes;

        v = VideoWriter([SAVE_PATH 'of/' name '_coarse_OF'],'Motion JPEG 2000');
        open(v)
        writeVideo(v,OF_scaled);
        close(v)
        
        filenum = filenum +1;
     
    end
    savename = [name(3:end-4) '_coarse_of_scale_data'];
    save([SAVE_PATH 'scale_data/' savename],'scale_data');
end

