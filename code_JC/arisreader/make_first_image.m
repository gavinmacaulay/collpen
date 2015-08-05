function data=make_first_image(data,smooth,imagexsize)
%Get_frame_first must be called before this function
%data = existing data structure formed in get_frame_first.m
%smooth = 1,4,or 8.  Generates vertual beams with linear interpolation
%This function adds to the data structure:
%  data.smooth = smooth
%  data.imagexsize = imagexsize = the image is imagexsize pixels wide
%  data.map.iysize = the image has length of iysize (function of ixsize)
%  data.map.svector = a vector to reorganize the data in frame to be the data in image (image space)
%  data.image = the uint8 image derived from frame
%  data.mapscale= [hs ws i0 j0]  See definitions below

data.smooth = smooth;

if data.smooth > 1
    frame = smooth1(data.frame,data.smooth,'expand');
else
    frame = data.frame;
end

frame(1,1)=0; %make sure first element is zero to "paint" outside of sector black

data.imagexsize=imagexsize;
nrows = data.numbeams*smooth -smooth +1;
data.map=mapscan(imagexsize,data.maxrange,data.minrange,14.4,nrows,512);

data.image=uint8(reshape(frame(data.map.svector),data.map.iysize,imagexsize));

% These parameters are used in function get_range_angle() to calaculate range and angle to a point in display
degtorad=0.0174533; % degrees to radians
ws = 2*data.maxrange*sin(14.25*degtorad)/data.imagexsize; % widthscale meters/pixels
hs = (data.maxrange - data.minrange*cos(14.25*degtorad))/data.map.iysize; % heightscale meters/pixels
i0 = data.maxrange/hs; % origin in height direction (pixel space)
j0 = data.imagexsize/2; % origin in width direction (pixel space)
data.mapscale =[hs,ws,i0,j0]; %used to go from pixel space to meter space in function get_range_angle()