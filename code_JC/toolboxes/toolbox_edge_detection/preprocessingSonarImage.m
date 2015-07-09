function I_exp_rec = preprocessingSonarImage(img, bg_img, denoising_method, param, debug, save)
% Methods 1-8 include a logaritmic conversion to transform multiplicative
% noise into additive.
%
% - param: For method 0, if param = -1 just background subtraction is 
%            applied
%          For methods 1-8, if pararam = 1 a wavelet transform is also 
%            applied. 
%          For methods 9-12, param establish the number of iterations (try
%            values between 25 - 50, although higher values can give good 
%            results too
% (~100).
%
% - Denoising_method
%   -1: No denoising
%   0: Background subtraction and TVG
%   1: Gaussian denoising
%   2: Median filter
%   3: Wiener filter
%   4: Median + average filter
%   5: Lucy-Richardson filter
%   6: Regularized filter
%   7: Conservative smoothing filter
%   8: Frost filter
%   9: DPAD
%   10: SRAD
%   11: DPAD + Median
%   12: SRAD + Median
%
% If the method is called with no parameters, initialize parameters

persistent Imax;
if(nargin == 0) %initialize
    Imax = [];
    I_exp_rec = [];
    return;
end

if(denoising_method == -1) % No denoising applied
    I_exp_rec = img;
    return;
end

% Background subtraction
img = abs(int8(img)-int8(bg_img));
img = uint8(img);
if param == -1 %% just bg subtraction
     I_exp_rec = img;
    return;
end   

% Normalization (TVG)
img = normalizeSonarImage(img);

if(denoising_method == 0 )
    I_exp_rec = img;
    return;
end

if( denoising_method < 8)
    img_mean = mean(img(:));   % Input image mean
    img = img+1; % To avoid NaN after ln
    img_ln = log(double(img));
    if(debug) % Restore the original values just for display
        img = img-1;
    end
    filter_txt='';
    if(param)
        filter_txt = 'Wavelet + ';
        sI = size(img_ln);
        wname = 'sym4';
        [img_ln, Ih, Iv, Id] = dwt2(img_ln,wname,'mode', 'per'); % Apply wavelet
    end
    
    switch denoising_method
        case 1
            G = fspecial('gaussian', [5 5], 2);
            img_filtered = imfilter(img_ln,G,'same'); % Gaussian filter
            filter_txt = [filter_txt 'Gaussian filter'];
        case 2
            img_filtered = medfilt2(img_ln, [5 5]);
            filter_txt = [filter_txt 'Median filter'];
        case 3
            % Problem: Knowing the point-spread function with which the input was
            % convolved.
            img_filtered = deconvwnr(img_ln, [1 0]); % Wiener filter
            filter_txt = [filter_txt 'Wiener filter'];
        case 4
            A = fspecial('average', [5 5]);
            img_filtered = medfilt2(img_ln, [5 5]);
            img_filtered = imfilter(img_filtered, A, 'same');
            filter_txt = [filter_txt 'Median + average filter'];
        case 5
            % Problem: Knowing the point-spread function with which the input was
            % convolved.
            img_filtered = deconvlucy(img_ln, [0 1 0], 5);
            filter_txt = [filter_txt 'Lucy-Richardson filter'];
        case 6
            % Problem: Knowing the point-spread function with which the input was
            % convolved.
            img_filtered = deconvreg(img_ln, [0 1 0]);
            filter_txt = [filter_txt 'Regularized filter'];
        case 7
            img_filtered = conservativeSmoothing(img_ln, 3); % Gaussian filter
            filter_txt = [filter_txt 'Conservative smoothing filter'];            
        otherwise 
            disp('Denoising method not valid');
            I_exp_rec = NaN;
            return
    end
    
    if(param)
        img_filtered =  idwt2(img_filtered, [], [], [],wname,sI); % Apply inverse wavelet
    end
    
    I_exp = exp(img_filtered); % Exponential reconstruction
    I_exp = I_exp-1; % restore correction
    
    I_exp(isnan(I_exp)) = 0;
    
    %a = find(I_exp>0);
    I_rec_mean = mean(I_exp(:));
    I_exp_rec = I_exp + (img_mean - I_rec_mean); % Mean correction
    I_exp_rec = round(I_exp_rec);
    if(debug)
        figure('Name',filter_txt);
        subplot(2,3,1)
        imagesc(img); title('Input image'); axis equal; axis tight; colorbar
        subplot(2,3,2)
        imagesc(img_ln); title('Log'); axis equal; axis tight; colorbar
        subplot(2,3,3)
        imagesc(img_filtered); title(filter_txt); axis equal; axis tight; colorbar
        subplot(2,3,4)
        imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
        subplot(2,3,5)
        imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
        subplot(2,3,6)
        I_noise = abs(img-I_exp_rec);
        imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar
    end
    
    if(save)
        imwrite(I_exp_rec,gray, [filter_txt '.eps']);
    end
    
else
    
    %   9: DPAD
    %   10: SRAD
    %   11: DPAD + Median
    %   12: SRAD + Median
    
    switch denoising_method
         case 8
            I_exp_rec = fcnFrostFilter(img);
            filter_txt = ['Frost filter'];
        case 9
            I_exp_rec = dpad(img,0.2,param,'cnoise',5,'big',5,'aja');
            I_exp_rec = uint8(I_exp_rec);
            filter_txt = ['DPAD ' int2str(param)];
        case 10
            I_exp_rec = dpad(img,0.2,param,'cnoise',5,'big',5,'simp');
            I_exp_rec = uint8(I_exp_rec);
            filter_txt = ['SRAD ' int2str(param)];
        case 11
            I_exp_rec = dpad(img,0.2,param,'cnoise',5,'big',5,'aja');
            I_exp_rec = medfilt2(I_exp_rec, [5 5]);
            I_exp_rec = uint8(I_exp_rec);
            filter_txt = ['DPAD ' int2str(param) ' + Median'];
        case 12
            I_exp_rec = dpad(img,0.2,param,'cnoise',5,'big',5,'simp');
            I_exp_rec = medfilt2(I_exp_rec, [5 5]);
            I_exp_rec = uint8(I_exp_rec);
            filter_txt = ['SRAD ' int2str(param) ' + Median'];
        otherwise 
            disp('Denoising method not valid');
            I_exp_rec = NaN;
            return
    end
    if(isempty(Imax))
       Imax =  max(I_exp_rec(:));
    else
        Imax = (Imax*4 + max(I_exp_rec(:)))/5;
    end
    
    
    I_exp_rec = double(I_exp_rec).*256./double(Imax);

    
    if(debug)
        figure('Name',filter_txt);
        subplot(1,2,1)
        imagesc(img); title('Input image'); axis equal; axis tight; colorbar
        subplot(1,2,2)
        imagesc(I_exp_rec); title(filter_txt); axis equal; axis tight; colorbar
    end
    
    if(save)
        imwrite(I_exp_rec,gray, [filter_txt '.jpg']);
    end
    
end

end