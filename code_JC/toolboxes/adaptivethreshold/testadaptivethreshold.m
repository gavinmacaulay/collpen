clear;close all;
im1=imread('sonar1.png');
im2=imread('tshape.png');

im1 = rgb2gray(im1);
bwim1=adaptivethreshold(im1,11,0.08,0);

bwim1 = imcomplement(bwim1);

level = graythresh(im1);
im2 = im1;
bwim2 = im2bw(im1,level);

%bwim2=adaptivethreshold(im2,15,0.02,0);
subplot(2,2,1);
imshow(im1);
subplot(2,2,2);
imshow(bwim1);
subplot(2,2,3);
imshow(im2);
subplot(2,2,4);
imshow(bwim2);