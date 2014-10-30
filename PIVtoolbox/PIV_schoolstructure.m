function [avspeed,dalpha,dcav,mcav2,c] = PIV_schoolstructure(xs,ys,us,vs,w, par)
%
% Estimate school structure parameters and average speed
%
% Input:
% xs, ys - positions
% us, vs - velocities (pixels per frame)
% w      - weigths
% par.templag - The number of frames to calculate the temporal correlation
% structure
%
% Output:
% avspeed : w-weighted average speed in the movie (pixels per frame)
% dalpha  : w-weighted temporal correlations
% cav     : w-weighted angular velocity (pixels per frame)
% c       : Average correlation length 
s = size(xs);

% Remove NaNs
ind=isnan(us)|isnan(vs);

% Include fish/no fish filter

% Calculate speed matrix
speed = hypot(us(:,:,:),vs(:,:,:));

% Calculate angle matrix
angle = atan2(us(:,:,:),vs(:,:,:));

% Average speed weighted by w
avspeed = sum(speed(~ind).*w(~ind)) / sum(w(~ind));

% temporal correlation structure vector
lag = 1:par.templag;

% Temporal correlation structure array
dalpha = zeros(size(angle,1),size(angle,2),par.templag);

for i=lag
    temp = nan(size(angle,1),size(angle,2),(size(angle,3)-i-1));
    w2 = nan(size(angle,1),size(angle,2),(size(angle,3)-i-1));
    % Loop over angle difference at given time lag (i) at each spatial cell
    for j=1:(size(angle,3)-i-1)
        temp(:,:,j) = abs(angle(:,:,j)-angle(:,:,j+i));
        % Combine the weights for each time step
        w2(:,:,j) = w(:,:,j) .* w(:,:,j+1);
    end
    % Change from [0 2*pi> to [0 pi>
    temp(temp>pi)=abs(temp(temp>pi) -2*pi);
    % Change from NaN to 0 in the weights and data
    temp(isnan(temp))=0;
    w2(isnan(w2))=0;
    % Take the average across time steps (dim 3)
    dalpha(:,:,i)=sum(temp.*w2,3)./sum(w2,3);
end

% Spatial curvature (curl)
dcav = zeros(size(angle,1),size(angle,2),size(angle,3));
mcav = zeros([size(angle,3) 1]);

% Loop over time steps
Cs = nan(s(1)*2-1,s(2)*2-1,s(3));
Ce = nan(s(1)*2-1,s(2)*2-1,s(3));

for i=1:size(us,3)
    % Combine the weights for each time step
    w2(:,:,j) = w(:,:,j) .* w(:,:,j+1);
    
    % Compute the curl (a) and the angular velocity (b) in radians per unit
    % time (which is half the |curl U|)
    [~,cav]=curl(xs(:,:,i), ys(:,:,i),us(:,:,i),vs(:,:,i));
    
    % weights
    w1 = w(:,:,i);
    % Set the NaN weights to zero
    w1(isnan(w1))=0;
    
    % Speed correlations
    us1sub = us(:,:,i);
    us1 = us1sub - nanmean(us1sub(:));
    vs1sub = vs(:,:,i);
    vs1 = vs1sub - nanmean(vs1sub(:));
    
    Cs(:,:,i) = cp_CorrelationLength(us1,vs1,w1);

    % Direction correlations
    s = hypot(us1sub,vs1sub);
    ev = vs1sub./s;
    eu = us1sub./s;
    ev1 = ev - nanmean(ev(:));
    eu1 = eu - nanmean(eu(:));
    Ce(:,:,i) = cp_CorrelationLength(ev1,eu1,w1);
    
    % Since we are using a center differencin scheme, the weights needs to
    % be recalculated across 3x3 pixels
    w2 = filter2([0 1 0;1 2 1;0 1 0]/6,w(:,:,i));
    w2(isnan(w2)|isnan(cav))=0;
    cav(isnan(cav))=0;

    dcav(:,:,i) = cav;
    % Take the average across each frame
    dum=abs(dcav(:,:,i)).*w2;
    mcav(i)=sum(dum(:))./sum(w2(:));
end

% The average cav across frames
mcav2= mean(mcav);

% Calculate the ranges for the correlations
mR = NaN([size(Cs,1) size(Cs,2)]);
i0=(size(Cs,1)-1)/2+1;
j0=(size(Cs,2)-1)/2+1;
for i=1:size(Cs,1)
    for j=1:size(Cs,2)
        mR(i,j) = sqrt((i-i0).^2 + (j-j0).^2);
    end
end
% Scale the ranges from PIV frame resolution to pixels 
dx = diff((xs(1,:,1)));
dx=dx(1);
dy = diff((ys(:,1,1)));
dy=dy(1);

c.mr = mR.*dx;

% Take the mean per range
r = unique(c.mr(:));
for i=1:length(r)
    ind=c.mr==r(i);
    c.cs(i)=nanmean(Cs(ind));
    c.ce(i)=nanmean(Ce(ind));
end
c.r = r;





