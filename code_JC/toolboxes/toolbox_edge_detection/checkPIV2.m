function [angles ranges dot_products relative_range] = ...
    checkPIV2(file, pr_frames, pr_x, pr_y, px_meter, ...
              fps, save_path, save_image, movieobj)
% 
% This function checks the performance of the PIV algorithm against a set 
% of manually labelled points that corresponds to fish positions.
%
% Inputs:
%   - file: The input PIVs are given by 'file' variable, wich refers to a .m file
%           with the following content:
%        · frames        : Frames to index the positions   
%        · frames_interpolated: Not used
%        · predator_x    : x dimension of the labelled position           
%        · interp_x      : Not used             
%        · predator_y    : x dimension of the labelled position      
%        · interp_y       : Not used       
%   - pr_frames: Frames to index the groundtruth positions to the PIVs
%   - pr_x: x position of the labelled position
%   - pr_y: y position of the labelled position 
%   - px_meter: deprecated
%   - fps: deprecated
%   - save_image: flag to indicate whether save the comparison as images
%   - save_path: path to save comparison images if save_image is active
%   - movieobj: descriptor of the video object pointing to the source video
%               from which PIVs have been calculated
%
% Outputs:
%   - angles: Angle difference between PIVs and groundtruth
%   - ranges: Lenght difference between PIVs and groundtruth
%   - dot_product: Dotproduct between PIVs and groundtrut
%   - relative_range: Normalized length difference between PIVs and groundtruth
  
disp('[checkPIV2]: Start');

angles          = [];
ranges          = [];
dot_products    = [];
relative_range  = [];
preys           = [];

load(file); % PIVs file

% Cluster manually labeled prey positions
for i = 3:3:length(pr_frames)
    fr = pr_frames(i-2:i);
    px = pr_x(i-2:i);
    py = pr_y(i-2:i);
    [x y u v] = averagePreyMovement(fr,px,py);
    preys = [preys ; [fr(2) x y u v]];
end

% The size of the image from which PIVs are obtained is necessary
I = read(movieobj, 1);
[r c n] = size(I);
if(n>1)
    I = rgb2gray(I);
end

if(save_image)
    f = figure('Units','normalized','Position',[0 0 0.5 1]);
    
end
[r c] = size(preys);
for i = 1:r
    
    if(save_image)
        clf(f,'reset');
        I = read(movieobj, preys(i,1));
        [r c n] = size(I);
        if(n>1)
            I = rgb2gray(I);
        end
        imagesc(I); axis equal; axis tight; colormap gray;
        hold on;
        img_save_path = [save_path '_' int2str(preys(i,1)) '.png'];
    end
    US = imresizeNN(us(:,:,preys(i,1)),size(I));
    VS = imresizeNN(vs(:,:,preys(i,1)),size(I));
    i_us = isnan(US);
    US(i_us) = 0;
    i_vs = isnan(VS);
    VS(i_vs) = 0;
    
    piv_u = single(US(round(preys(i,3)),round(preys(i,2)))); % In pixels/frame
    piv_v = single(VS(round(preys(i,3)),round(preys(i,2)))); % In pixels/frame
 
    
    vvv = vs(:,:,preys(i,1)); % In pixels/frame
    uuu = us(:,:,preys(i,1)); % In pixels/frame
    i_us = isnan(uuu);
    uuu(i_us) = 0;
    i_vs = isnan(vvv);
    vvv(i_vs) = 0;
    
    xxx = xs(:,:,preys(i,1));
    yyy = ys(:,:,preys(i,1));
    prey_u = single(preys(i,4)); % In pixels/frame
    prey_v = single(preys(i,5)); % In pixels/frame
    prey_x = single(preys(i,2));
    prey_y = single(preys(i,3));
    
    if(save_image)
        quiver(xxx,yyy,uuu,vvv,'color',[0 0 1]);
        quiver(prey_x,prey_y,prey_u,prey_v,4,'g');
        quiver(prey_x,prey_y,piv_u,piv_v,4,'r');
        
        plot(pr_x((i*3)-2:1:i*3),pr_y((i*3)-2:1:i*3),'.g');
        F = getframe(f);
        saveas(F, img_save_path);
        
    end
           
    [prey_r prey_len] = cartesian2Polar(prey_u,prey_v);
    [piv_r piv_len] = cartesian2Polar(piv_u,piv_v);
    
    len             = piv_len - prey_len;
    relative_range  = [relative_range ; piv_len*100/prey_len];
    angle           = getAngleTwoVectors([prey_u,prey_v],[piv_u,piv_v]);
    dot_product     = dot([prey_u,prey_v],[piv_u,piv_v]);
    angles          = [angles ; angle];
    ranges          = [ranges ; len];
    dot_products    = [dot_products ; dot_product];
    
end
disp('[checkPIV2]: End');

end

