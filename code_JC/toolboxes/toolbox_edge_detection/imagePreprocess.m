function I = PIV_imagePreprocess(img, bg, params)
%
% Image preprocessing to isolate foreground objects
%
% Input:
%   - img : input image
%   - bg : Background image (for subtraction)
%   - params.threshold_method : thresholding technique to use (0 =  fixed
%   threshold with given level; 1 = fixed threshold with Otsu level; 2 =
%   local adaptive threshold
%   - params.threshold_level : level for fixed threshold
%   - params.window_size : local adaptive threshold only
%   - params.thickening_level : thickens objects by adding pixels to the exterior of objects
%   - params.strel_size : size of the structuring element for the closing
%   - params.opening_iterations
%   - params.debug : display intermediate results
%   - params.apply_denoising : denoising techinque to apply (0: no
%   denoising; 1: wavelet; 2: median)
%
% Output:
%   - I : Preprocessed image
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

   
    sub = imsubtract(img, bg);


    
    
    switch params.apply_denoising
        case 0 % no denoising
            img2 = sub;
        case 1 % Wavelet
            img2 = uint8(waveletDenoise(sub));
        case 2 % Median
            img2 = medfilt2(sub);
        otherwise % no denoising
            img2 = sub;

    end
    
    colormap pink;
    
    
    img3 = imgThresholding(img2,params.threshold_method,params.threshold_level, params.window_size);
    

    
    % Removes isolated pixels (individual 1's surrounded by 0's)
   % img3 = bwmorph(img3, 'clean');
    
    img4 = bwmorph(img3,'thicken', params.thickening_level);
    
    se = strel('disk',params.strel_size);
    img4 = imclose(img4,se);
    
    
    I = bwmorph(img4,'open', params.opening_iterations);

    if(params.debug)
      subplot(231); imagesc(img); title('Input image'); axis equal;
      subplot(232); imagesc(sub); title('BG subtraction'); axis equal;
      subplot(233); imagesc(img2); title('Denoised'); axis equal;
      subplot(234); imagesc(img3); title('Threshold');  axis equal;
      subplot(235); imagesc(img4); title('Close'); axis equal;
      subplot(236); imagesc(I); title('Open'); axis equal;
    end 
end


%% This wavelet performs better than the one implemented in waveletLowPass
% function
function I = waveletDenoise(img)

% A value of N = 4 provides good performande whilst keeping the psnr
% acceptably high (around 30)
 [thr,sorh,keepapp] = ddencmp('den','wv',img);
  I = wdencmp('gbl',img,'sym4',4,thr,sorh,keepapp);

end


%% Perform thresholding

function I = imgThresholding(img, option, threshold, window_size)

% IMGTHRESHOLD A thresholding function that allows to select among three
% techniques: - performing a fixed thresholding based on an input parameter
%             - performing a fixed thresholding based on the Otsu threshold
%               level
%             - Performing a local adaptive thresholding based on Xiong's
%               method http://www.mathworks.com/matlabcentral/fileexchange/8647-local-adaptive-thresholding
%   I = imgThreshold(img, option, threshold, window_size) outputs a binary image I
%
%   Arguments:
%       - img : input image
%       - option : selects what technique will be used 
%           1 = fixed thresholding given threshold argument
%           2 = Otsu-based fixed thresholding
%           3 = Local adaptive thresholding with a local threshold =
%           threshold and a wintow size = window_size
%               In this case, threshold argument must be a double [0,1] and
%               window_size an integer

switch option

    case 0 % Fixed thresholding
        I = im2bw(img,threshold);
        
    case 1 % Fixed thresholding with Otsu threshold (no parameter required)
        level = graythresh(img);
        I = im2bw(img,level);
        
    case 2 % Adaptive thresholding
        I = adaptivethreshold(img, window_size, threshold,0);
        I = imcomplement(I); %black bg / white fg
        
    otherwise
        disp('Incorrect thresholding option');

end
end