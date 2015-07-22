%%%%%%%% Denoising tests 


%%% Image normalization + bg sub + mean estimation + log + Gaussian +
%%% exp + mean correction

close all
clear

I = rgb2gray(imread('/Volumes/Datos/collpen/collpen/imgs_test/sonar1.png'));
bg = imread('/Volumes/Datos/collpen/collpen/imgs_test/bg.bmp'); % Load background

 I = preprocessingSonarImage(I,bg,9,1,0,0);
% I = preprocessingSonarImage(I,bg,9,25,0,0);
% keyboard

tic
I_sub = abs(I-double(bg));

I_norm = normalizeSonarImage(I_sub); % Image range normalization
I_mean = mean(I_norm(:));   % Image mean
I_norm = I_norm + 1; % Correction to avoid NaN after log
I_ln = log(double(I_norm)); % Image log
toc

figure('Name','Preprocessing');
subplot(1,4,1)
imagesc(I); title('Input image'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_sub); title('BG sub'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_norm); title('Normalized'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_ln); title('Log'); axis equal; axis tight; colorbar

%% Test 0 Detail Preserving Anosotropic Diffusion for Speckle Filtering (DPAD)

% http://www.mathworks.com/matlabcentral/fileexchange/36906-detail-preserving-anosotropic-diffusion-for-speckle-filtering--dpad-
 
% DPAD implements two different anisitropic diffusion based schemes for speckle filtering:
% 
% -SRAD (Speckle Reducing AD) 
% -DPAD (detail Preserving AD)

I_norm = I_norm-1;
I_norm = single(I_norm);

%%
close all

% Noise estimated over absolute deviation of median
tic
%I_yuest = medfilt2(I_yuest, [5 5]); 
I_yuest = dpad(I_norm,0.2,100,'cnoise',5,'big',5,'yuest'); 
I_yuest = medfilt2(I_yuest, [5 5]); 
I_yuest = uint8(I_yuest);
I_yuest = double(I_yuest)*256/double(max(I_yuest(:)));
toc

imwrite(I_yuest,gray,'yuest+median-100step.jpg');
fig =  figure;imagesc(I_yuest);
 axis equal; axis tight; colorbar
 saveas(fig,'matlab-yuest+median-100step.jpg');

 % SRAD
tic
%I_srad = medfilt2(I_srad, [5 5]); 
I_srad = dpad(I_norm,0.2,100,'cnoise',5,'big',5,'simp'); 
I_srad = medfilt2(I_srad, [5 5]); 
I_srad = uint8(I_srad);
I_srad = double(I_srad)*256/double(max(I_srad(:)));
toc

imwrite(I_srad,gray,'srad+median-100step.jpg');
 fig = figure;imagesc(I_srad);
 axis equal; axis tight; colorbar
  saveas(fig,'matlab-srad+median-100step.jpg');

 
% DPAD

tic;
%I_dpad = medfilt2(I_dpad, [5 5]); 
I_dpad = dpad(I_norm,0.2,100,'cnoise',5,'big',5,'aja'); 
I_dpad = medfilt2(I_dpad, [5 5]); 
I_dpad = uint8(I_dpad);
I_dpad = double(I_dpad).*256./double(max(I_dpad(:)));
toc
  
imwrite(I_dpad,gray,'dpad+median-100step.jpg');
fig =  figure;imagesc(I_dpad);
 axis equal; axis tight; colorbar
  saveas(fig,'matlab-dpad+median-100step.jpg');

  
% Frost
  
tic
I_frost = fcnFrostFilter(I_norm);
toc


figure('Name','Frost filter');
imagesc(I_frost); title('Frost'); axis equal; axis tight; colorbar

 %%% There is no much difference 

%% Test 1 ... log + Gaussian filter + exp ...

G = fspecial('gaussian', [5 5], 2);
tic
Iln_gauss = imfilter(I_ln,G,'same'); % Gaussian filter
toc

I_exp = exp(Iln_gauss); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));

I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Gaussian');
subplot(1,4,1)
imagesc(Iln_gauss); title('Gaussian'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar



%% Test 3 ... log + median filter + exp ...
tic
Iln_median = medfilt2(I_ln, [5 5]); % Gaussian filter
toc

I_exp = exp(Iln_median); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));


I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Median 5x5 filter');
subplot(1,4,1)
imagesc(Iln_median); title('Median'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar

%% Test 4 ... log + Wiener filter + exp ...
% http://www-rohan.sdsu.edu/doc/matlab/toolbox/images/deblurr6.html#8329

% Problem: Knowing the point-spread function with which the input was
% convolved.
tic
Iln_wiener = deconvwnr(I_ln, [1 0]); % Wiener filter
toc

I_exp = exp(Iln_wiener); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));


I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Wiener filter');
subplot(1,4,1)
imagesc(Iln_wiener); title('Wiener filter'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar

%% Test 5 ... log + median filter + average filter + exp ...

A = fspecial('average', [64 64]);

tic
Iln_median = medfilt2(I_ln, [5 5]); % Gaussian filter
Iln_median = imfilter(Iln_median, A, 'same');
toc

I_exp = exp(Iln_median); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));


I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Median + average filter');
subplot(1,4,1)
imagesc(Iln_median); title('Median + Mean'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar

%% Test 6 ... log +  Lucy-Richardson filter + exp ...
% http://www-rohan.sdsu.edu/doc/matlab/toolbox/images/deblurr8.html#8550

% Problem: Knowing the point-spread function with which the input was
% convolved.
tic
Iln_wiener = deconvlucy(I_ln, [0 1 0], 5); % Wiener filter
toc

I_exp = exp(Iln_wiener); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));


I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Lucy-Richardson filter');
subplot(1,4,1)
imagesc(Iln_wiener); title('Wiener filter'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar

%% Test 7 ... log +  Regularized filter + exp ...
% http://www-rohan.sdsu.edu/doc/matlab/toolbox/images/deblurr7.html#8471

% Problem: Knowing the point-spread function with which the input was
% convolved.
tic
Iln_reg = deconvreg(I_ln, [0 1 0]); % Wiener filter
toc

I_exp = exp(Iln_reg); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));


I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Regularized filter');
subplot(1,4,1)
imagesc(Iln_reg); title('Regularized filter'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar

%% Test 8 ... log + Conservative smoothing filter + exp ...
% http://homepages.inf.ed.ac.uk/rbf/HIPR2/csmooth.htm
tic
Iln_consmo = conservativeSmoothing(I_ln, 5); % Gaussian filter
toc

I_exp = exp(Iln_consmo); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));


I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Conservative smoothing filter');
subplot(1,4,1)
imagesc(Iln_consmo); title('Conservative smoothing'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar

%% Test 9 ... log + wavelet + gaussian + iwavelet + exp ...
% http://homepages.inf.ed.ac.uk/rbf/HIPR2/csmooth.htm
tic
% calculate wavelet
sI = size(I_ln);
wname = 'sym4';
[Ia, Ih, Iv, Id] = dwt2(I_ln,wname,'mode', 'per');
% Apply gaussian blur to Vertical, Horizontal and Diagonal components
G = fspecial('gaussian', [100,100], 50);
Blv = imfilter(Iv,G,'same');
Blh = imfilter(Ih,G,'same');
Bld = imfilter(Id,G,'same');
%I_ln_wavelet_gauss = idwt2(Ia, Blh, Blv, Bld,wname,sI);

I_ln_wavelet_gauss = idwt2(Ia, [], [], [],wname,sI);

toc

I_exp = exp(I_ln_wavelet_gauss); % Exponential reconstruction
I_exp = I_exp-1; % restore correction

%a = find(I_exp>0);
I_rec_mean = mean(I_exp(:));
I_exp_rec = I_exp + (I_mean - I_rec_mean); % Mean correction
I_exp_rec_mean = mean(I_exp_rec(:));


I_noise = abs(double(I_norm)-I_exp_rec);

figure('Name','Conservative smoothing filter');
subplot(1,4,1)
imagesc(I_ln_wavelet_gauss); title('Wavelet + gauss smoothing'); axis equal; axis tight; colorbar
subplot(1,4,2)
imagesc(I_exp); title('Exp'); axis equal; axis tight; colorbar
subplot(1,4,3)
imagesc(I_exp_rec); title('Mean corrected'); axis equal; axis tight; colorbar
subplot(1,4,4)
imagesc(I_noise); title('Noise'); axis equal; axis tight; colorbar
