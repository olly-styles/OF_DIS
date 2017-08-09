function scaled_im = scale_optical_folow(im,new_min,new_max)
% Rescales an image to the specified range

    old_min = -20;
    old_max = 20;
    
    scaled_im = (((new_max - new_min) * (im - old_min)) / (old_max - old_min)) + new_min; 