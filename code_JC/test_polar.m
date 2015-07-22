 im=double(imread('/imgs_test/predmodel2013_Brown net_didson_block46_sub1_BG.bmp'));
 %im = imrotate(im,-90);
 fim=fft2(im);
 pcimg=imgpolarcoord(im);
 fpcimg=imgpolarcoord(fim);
 figure; subplot(2,2,1); imagesc(im); colormap gray; axis image;
 title('Input image');  subplot(2,2,2);
 imagesc(log(abs(fftshift(fim)+1)));  colormap gray; axis image;
 title('FFT');subplot(2,2,3); imagesc(pcimg); colormap gray; axis image;
 title('Polar Input image');  subplot(2,2,4);
 imagesc(log(abs(fpcimg)+1));  colormap gray; axis image;
 title('Polar FFT');
 
 %%
  im=double(imread('/imgs_test/polar.png'));
  
 im2 = imagecartesian2polar(im, 83, 1090 ,26,0);
 axis equal
%  
%  figure;
%  image = get(im2,'CData');
%  imagesc(imrotate(image,180,'bilinear'));
%  axis equal
 
 
 
%%

%Loading an image and adding some noise. 

n = 256;
I = rgb2gray(imread('monkeyPic.jpg'));
% reduce size to speed up
I = I(end/2-n/2+1:end/2+n/2,end/2-n/2+1:end/2+n/2);
%I = rescale(I,15,240);
% add noise
sigma = 0.12 * (max(I(:))-min(I(:)));
In = double(I) + double(sigma)*randn(n);
In = uint8(In);
Jmin = 2;

% Orthogonal 2D wavelet transform and thresholding.
% 2D wavelet transform
Iw = perform_wavelet_transform(In,Jmin,+1); % compute the transform up to scale Jmin 
% thresholding
T = 0.01*sigma;
%IwT = Iw; 
IwT = Iw .* (abs(Iw)>T);
% inverse transform
Iwav = perform_wavelet_transform(IwT,Jmin,-1);

% Plotting the thresholded transform.
clf;
subplot(1,2,1);
plot_wavelet(Iw, Jmin); 
subplot(1,2,2);
plot_wavelet(IwT, Jmin);
colormap gray(256);


%% wavelet test

I = rgb2gray(imread('monkeyPic.jpg'));

Y = double(I) + 18*randn(size(I));



sI = size(Y);

% Calculate wavelet
wname = 'sym4';
[Ia, Ih, Iv, Id] = dwt2(Y,wname,'mode', 'per');

% Apply gaussian blur to Vertical, Horizontal and Diagonal components
G = fspecial('gaussian', [10,10], 5);
Blv = imfilter(Iv,G,'same');
Blh = imfilter(Ih,G,'same');
Bld = imfilter(Id,G,'same');

% Inverse wavelet to regenerate image

xd1 = idwt2(Ia, Blh, Blv, Bld,'sym4',sI);

xd2 = idwt2(Ia, [], [], [],'sym4',sI);

% A value of N = 4 provides good performande whilst keeping the psnr
% acceptably high (around 30)
 [thr,sorh,keepapp] = ddencmp('den','wv',Y);
 % xd1 = wdencmp('gbl',Y,'sym4',2,thr,sorh,keepapp);
  psnr_gauss = psnr(xd1, double(I) )
  
 %xd2 = wdencmp('gbl',Y,'sym4',4,thr,sorh,keepapp);
  psnr_elim_coefs = psnr(xd2, double(I) )

 xd3 = wdencmp('gbl',Y,'sym4',4,thr,sorh,keepapp);
  psnr_wdencmp =  psnr(xd3, double(I) )

colormap pink;
% subplot(221)
% imagesc(I); title('Original Image');
% subplot(222);
% imagesc(Y); title('Noisy Image');
% subplot(223)
% imagesc(xd); title('Denoised Image');

subplot(221)
imagesc(Y); title('Original Image');
subplot(222);
imagesc(xd1); title('gauss');
subplot(223)
imagesc(xd2); title('Eliminate coefs');
subplot(224)
imagesc(xd3); title('wdencmp');

%% Read in and threshold an intensity image. 
% Display the labeled objects using the jet colormap, 
% on a gray background, with region boundaries outlined in white.

I = imread('monkeyPic.jpg');
BW = im2bw(I, graythresh(I));

[B,L] = bwboundaries(BW,'noholes');
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

%% Read in and display a binary image. 
% Overlay the region boundaries on the image. 
% Display text showing the region number (based on the label matrix) next to every boundary. 
% Additionally, display the adjacency matrix using the MATLAB spy function.

I = imread('monkeyPic.jpg');
BW = im2bw(I, graythresh(I));

[B,L,N,A] = bwboundaries(BW);
figure, imshow(BW); hold on;
colors=['b' 'g' 'r' 'c' 'm' 'y'];
for k=1:length(B)
    boundary = B{k};
    cidx = mod(k,length(colors))+1;
    plot(boundary(:,2), boundary(:,1),...
         colors(cidx),'LineWidth',2);
    %randomize text position for better visibility
    rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
    col = boundary(rndRow,2); row = boundary(rndRow,1);
    h = text(col+1, row-1, num2str(L(row,col)));
    set(h,'Color',colors(cidx),...
        'FontSize',14,'FontWeight','bold');
end
figure; spy(A);

%% Display object boundaries in red and hole boundaries in green.

I = imread('monkeyPic.jpg');
BW = im2bw(I, graythresh(I));

[B,L,N] = bwboundaries(BW);
figure; imshow(BW); hold on;
for k=1:length(B),
    boundary = B{k};
    if(k > N)
        plot(boundary(:,2),...
            boundary(:,1),'g','LineWidth',2);
    else
        plot(boundary(:,2),...
            boundary(:,1),'r','LineWidth',2);
    end
end

%% Display parent boundaries in red (any empty row of the adjacency matrix belongs to a parent) and their holes in green.

I = imread('monkeyPic.jpg');
BW = im2bw(I, graythresh(I));

[B,L,N,A] = bwboundaries(BW);
figure; imshow(BW); hold on;
for k=1:length(B),
    if(~sum(A(k,:)))
       boundary = B{k};
       plot(boundary(:,2),...
           boundary(:,1),'r','LineWidth',2);
       for l=find(A(:,k))'
           boundary = B{l};
           plot(boundary(:,2),...
               boundary(:,1),'g','LineWidth',2);
       end
    end
end




%% Vector rotation

theta = 5;


O = [5 ; -4];
A = [2 ; 3];

R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

vA = R*A;

quiver(O(1),O(2),A(1)+O(1),A(2)+O(2))
hold on 
quiver(O(1),O(2),vA(1)+O(1),vA(2)+O(2))
hold off

%%

theta = 90;
v = [1 2 3 4];

p = [v(3) - v(1) , v(4) - v(2)];

pos_x = 0;
p1 = [1 3];
p2 = [2 -5];
hold on
grid on
colormap HSV
for pos_x=0:1:100
pos_y = -((pos_x - p1(1)) / (p2(1) - p1(1)) * (p2(2) - p1(2))) + p1(2);
plot(pos_x, pos_y, '-r*');
end

for pos_y=-100:1:100
pos_x = ((pos_y - p1(2))/ (p2(2) - p1(2)) * (p2(1) - p1(1))) + p1(1);
plot(pos_x, pos_y, 'd');
end



%%


close all
clear
I = imread('monkeyPic.jpg');
bw = im2bw(I,graythresh(I));
bw = uint8(1-bw);
angle = 180;
step = 180;
predator_vect = [100 200 300 40];



x = [436;   429 ;   430 ;   433 ;   433 ;   432 ;   430 ;   427 ;   424 ;   421 ;   419 ;   417 ;  418 ;   417 ;   414 ;   410 ;   408 ;   408 ;   411 ;   413 ;   406 ;   397] ;
y = [202;   218;    230;    241;    251;    261;    270;    278;    287;    297;    307;    318;   324;    327;    333;    340;    350;    362;    371;    377;    386;    399]
colormap gray
grid on

for i = 1:1:size(x,1)-1
    predator_vect = [x(i) y(i) x(i+1) y(i+1)]
    getBoundaries(bw, predator_vect, angle, step,1);
    subplot(1,2,1);
    quiver(predator_vect(1), predator_vect(2), predator_vect(3)-predator_vect(1), predator_vect(4)-predator_vect(2),200);
    hold off
    ginput
end


% getBoundaries(bw, predator_vect, angle, step,1);
% hold on
% subplot(1,2,1);
% quiver(predator_vect(1), predator_vect(2), 1.5*(predator_vect(3)-predator_vect(1)), 1.5*(predator_vect(4)-predator_vect(2)));
% hold off




%% Test smoothing spline 
clear all
close all


xi = (0:.05:1);
q = @(x) x.^3;
yi = q(xi);
randomStream = RandStream.create( 'mcg16807', 'Seed', 23 );
ybad = yi+.3*(rand(randomStream, size(xi))-.5);
p = .5;
xxi = (0:100)/100;
ys = csaps(xi,ybad,p,xxi);
plot(xi,yi,':',xi,ybad,'x',xxi,ys,'r-')
title('Clean Data, Noisy Data, Smoothed Values')
legend( 'Exact', 'Noisy', 'Smoothed', 'Location', 'NorthWest' )


yy = zeros(5,length(xxi));
p = [.6 .7 .8 .9 1];
for j=1:5
   yy(j,:) = csaps(xi,ybad,p(j),xxi);
end
hold on
plot(xxi,yy);
hold off
title('Smoothing Splines for Various Values of the Smoothing Parameter')
legend({'Exact','Noisy','p = 0.5','p = 0.6','p = 0.7','p = 0.8', ...
        'p = 0.9', 'p = 1.0'}, 'Location', 'NorthWest' )

    epsilon = ((xi(end)-xi(1))/(numel(xi)-1))^3/16;
1 - 1/(1+epsilon)

plot(xi,yi,':',xi,ybad,'x')
hold on
labels = cell(1,5);
for j=1:5
   p = 1/(1+epsilon*10^(j-3));
   yy(j,:) = csaps(xi,ybad,p,xxi);
   labels{j} = ['1-p= ',num2str(1-p)];
end
plot(xxi,yy)
title('Smoothing Splines for Smoothing Parameter Near Its ''Magic'' Value')
legend( [{'Exact', 'Noisy'}, labels], 'Location', 'NorthWest' )
hold off

p = 1/(1+epsilon*10^3);
yy = csaps(xi,ybad,p,xxi);
hold on
plot( xxi, yy, 'y', 'LineWidth', 2 )
title( sprintf( 'The Smoothing Spline For 1-p = %s is Added, in Yellow', num2str(1-p) ) )
hold off


%% Smothing spline

clear all
close all

load('/Volumes/Datos/collpen/predator/white_net/seq2/predmodel2013_TREAT_White net_didson_block59_sub1.mat');


[frames_interp x_interp] = smoothingSpline(frames, predator_x)


plot(frames, predator_x, '.r', frames_interp,x_interp,'b');


%% Normalize sonar data

clear
close all


I = rgb2gray(imread('sonar1.png'));
figure; imagesc(I);
title('I1');
axis equal
axis tight

%I = imrotate(I,180);
[h w] = size(I);

I = double(I);

for i = 1:h
    I2(i,:) = I(i,:) * 20 * log(h-i+1);
end

I2 = I2/255;

%I2 = imrotate(I2,180);

figure; imagesc(I2);
title('I2');
axis equal
axis tight



%% Read mp4

filepath = '/Volumes/Datos/collpen/predator/test/block1_2_700_975.mp4'
%info     = aviinfo(filepath);
movieobj = VideoReader(filepath);
    
n    = movieobj.NumberOfFrames-1
    RGB  = read(movieobj, 1);
imagesc(RGB);

