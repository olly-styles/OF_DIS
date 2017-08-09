function scaled_im = scale_optical_flow(im,new_min,new_max,old_min,old_max)
% Rescales an image to the specified range

    scaled_im = (((new_max - new_min) * (im - old_min)) / (old_max - old_min)) + new_min; 