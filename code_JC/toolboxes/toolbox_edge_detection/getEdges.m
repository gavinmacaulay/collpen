function [edges, regions] = getEdges(filepath, bg_image, msg)
% This function preprocess images in a video sequence to detect the edges
% contained in them. The main steps are commented in the code
%
% Inputs:
%   - filepath : path to the .avi file to analyze
%   - bg_image : background image to eliminate noise
%   - msg : binary variable to allow displaying messages
%
% Output:
%   - edges : edges found in the image. This is a bi-dimensional matrix
%   with x,y positions
%   - regions : matrix with the same dimension of the frames containing
%   labels associated to each independent region detected in the image to
%   allow further tracking
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com



% 1) Opening movie object
dispMsg(msg,'[findEdges]: ..Loading movie')
movieobj = VideoReader(filepath);


% 2) Setting up image stack
dispMsg(msg,'[findEdges]: ..Setting up image stack')
RGB         = uint16(read(movieobj, 1));
nf          = movieobj.NumberOfFrames;
[m n z]     = size(RGB);
Is          = zeros(m,n,nf);

% 3) Loop among the whole sequence
for f=1:1:nf
%   3.1) Load image
    img = rgb2gray(read(movieobj, f));
%   3.2) Denoise. In this case, the background must have also been denoised
%   using the same technique prior to its computation. Comment this line otherwise
    img2 = uint8(waveletDenoise(img));
%   3.3) Background subtraction    
    sub = imsubtract(img2, bg_image);
%   3.4) Thresholding to separate regions from background    
    img3 = imgThreshold(sub,0.10);
%   3.5) Remove isolated pixels (individual 1s that are surrounded by 0s)
    img3 = bwmorph(img3, 'clean' , 1);
%   3.6) Increase the size of the remaining spots to ensure connectivity    
    img4 = bwmorph(img3,'thicken',4);    
    se = strel('disk',10);
    img4 = imclose(img4,se);
%   3.7) eliminate isolated pixels (if any)
    img5 = bwmorph(img4,'open',4);
%   3.8) Obtain regions and edges
    [edges regions] = bwboundaries(img5,4,'noholes');
%   3.9) Display results    
    colormap pink;
    subplot(231);    
    imshow(label2rgb(regions, @gray,[.5 .5 .5]));    
    hold on
    for k = 1:length(edges)
        boundary = edges{k};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth',1);
    end
    subplot(232); imagesc(img2); title('Wavelet');
    subplot(233); imagesc(sub); title('BG subtraction');
    subplot(234); imagesc(img3); title('Threshold');
    subplot(235); imagesc(img4); title('close');
    subplot(236); imagesc(img5); title('open');
end
end


%% Wavelet low pass filter

function I = waveletLowPass(img)

sI = size(img);

% Calculate wavelet
wname = 'sym4';
[Ia, Ih, Iv, Id] = dwt2(img,wname,'mode', 'per');

% Apply gaussian blur to Vertical, Horizontal and Diagonal components (test
% other filters - pending)
G = fspecial('gaussian', [10,10], 5);
Blv = imfilter(Iv,G,'same');
Blh = imfilter(Ih,G,'same');
Bld = imfilter(Id,G,'same');

% Inverse wavelet to regenerate image

I = idwt2(Ia, Blh, Blv, Bld,'sym4',sI);

%I = idwt2(Ia, [], [], [],'sym4',sI);

end


% This wavelet performs better than the one implemented in waveletLowPass
% function
function I = waveletDenoise(img)

% A value of N = 4 provides good performande whilst keeping the psnr
% acceptably high (around 30)
[thr,sorh,keepapp] = ddencmp('den','wv',img);
I = wdencmp('gbl',img,'sym4',4,thr,sorh,keepapp);

end




%% Perform BG subtraction

function I = bgSubtraction(frame, BG)

I = abs(frame-BG);
%imshow(I);

end

%% Perform thresholding

function I = imgThreshold(img, threshold)

I = im2bw(img,threshold);
%imshow(I);

end

%% Performs closing morphological operations to fill gaps
function I = imgClose(img, close_struct)

% Create structuring element
se = strel('rectangle',close_struct.kernel);

I = img;

% Run morphological filter 'iterations' times
for i=1:1:close_struct.iterations
    I = imclose(I, se);
    %imshow(I);
end

end


%% Performs opening morphological operations to remove outliers
function I = imgOpen(img, open_struct)

% Create structuring element
se = strel('diamond',open_struct.kernel);

I = img;

% Run morphological filter 'iterations' times
for i=1:1:open_struct.iterations
    I = imopen(I, se);
    %imshow(I);
end

end

%% Preprocessing to isolate regions of interest
function I = imgPreprocess(img, bg_img, open_struct, close_struct, threshold)

%I = rgb2gray(img);
I = bgSubtraction(img, bg_img);
I1 = imgThreshold(I, threshold);
%I = imgClose(I,close_struct);
%I = imgOpen(I, open_struct);
iterations = 8;
% I = bwmorph(I1,'bothat',iterations);
% set(gcf,'name','bothat');
% imshow(I);
figure;
set(gcf,'name','close');
I = bwmorph(I1,'close',2*iterations);
imshow(I);
% figure;
% set(gcf,'name','bridge');
% I = bwmorph(I1,'bridge',iterations);
% imshow(I);
% figure;
% set(gcf,'name','diag');
% I = bwmorph(I1,'diag',iterations);
% imshow(I);
figure;
set(gcf,'name','thicken');
I = bwmorph(I1,'thicken',iterations/2);
I = bwmorph(I,'close',3);
imshow(I);
% figure;
% set(gcf,'name','majority');
% I = bwmorph(I1,'majority',iterations);
% imshow(I);
%figure;
% set(gcf,'name','tophat');
% I = bwmorph(I1,'tophat',iterations);
% imshow(I);
end



function dispMsg(on, msgtext)
if on
    disp(msgtext);
end
end