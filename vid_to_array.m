function vid_array = vid_to_array(path,rgb)
% Reads in a video from specified path and converts to array

  if nargin < 2
    rgb =   1
  end

vid = VideoReader(path);
nframes = vid.NumberOFFrames;
vid_height = vid.Height;
vid_width = vid.Width;

if rgb
    vid_array = zeros(vid_height,vid_width,3,nframes,'uint8');
    % Read the first frame
    vid_array(:,:,:,1) = read(vid,1);

    % Read the rest of the video
    for i = 2 : nframes
        vid_array(:,:,:,i) = read(vid,i);
    end

else
    vid_array = zeros(vid_height,vid_width,nframes,'uint8');
    % Read the first frame
    vid_array(:,:,1) = read(vid,1);

    % Read the rest of the video
    for i = 2 : nframes
        vid_array(:,:,i) = read(vid,i);
    end
end

