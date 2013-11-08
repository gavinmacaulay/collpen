function [image, filepathbg] = PIV_schoolstructure(folder, avifilename, par)
%
% Estimate school structure parameters and average speed 
% 
% Input:
% file          : The PIV mat file (Avi file name from didson without the .avi extension)
% filedir       : Directory to store output files
%
% parstr        : Parameter structure
% 
% The inuput file should contain:

load(fullfile(folder,[avifilename,'_RAWPIV.mat']))

% Remoce NaNs
ind=isnan(snrs);

% Include fish/no fish filter
%TODO
fish = true(size(snrs));
fish(ind)=false;

% Calculate weights
msnrs=par.msnrs;
ssnrs=par.ssnrs;
w =.5*(1+erf((snrs-msnrs)/sqrt(2*ssnrs^2)));

% Quality weights
qlt = w.*fish;

% Calculate speed
speed = hypot(us(:,:,:),vs(:,:,:));
% Calculate angle matrix
angle = atan2(us(:,:,:),vs(:,:,:));

% Average speed weighted by quality and fish mask
avspeed = sum(speed(~ind).*qlt(~ind)) / sum(qlt(~ind));

% temporal correlation structure
lag = 1:par.templag;

uangle= unwrap(angle(:,:,:),[],3);
dalpha = zeros(size(uangle,1),size(uangle,2),par.templag);

for i=lag
    temp = nan(size(uangle,1),size(uangle,2),(size(uangle,3)-i-1));
    for j=1:(size(uangle,3)-i-1)
        temp(:,:,j) = abs(uangle(:,:,j)-uangle(:,:,j+i));
    end
    % Unweigthed mean, needs to be refined
    dalpha(:,:,i)=mean(temp,3);
end

meanalpha = nan([1 length(lag)]);
for i=lag
    dum =dalpha(:,:,i).*qlt(:,:,;
    meanalpha(i) = mean(dum(:));
end

% Spatial correlation structure



