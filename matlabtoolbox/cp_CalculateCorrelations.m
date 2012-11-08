function[correlation] = cp_CalculateCorrelations(X,par)
%
% This function reads the positions and velocity for points in an
% ecuclidean space and calculates the correlation as a function of range
%
% Output:
% correlation.corr_range : The range bins
% correlation.phi(i)   : Polarisation over the full image for frame i
% correlation.N(i)     : The number of targets for frame i
% correlation.meanV(i) : The mean velocity (direction) for frame i
% correlation.time(i)  : The time for each frame i
% correlation.C        : The correlation for each frame i and rangebin 
% correlation.CLength : The correlation length for each frame (zero crossing)
%
% Input:
% X{i}  = [1 i matlabtime NaN NaN x_position y_position dx_speed dy_speed;
%          2 i matlabtime NaN NaN x_position y_position dx_speed dy_speed];
%         where 'i' denotes frame number
%
% Parameters:
% par.dircorrelation = logical(0) - Velocity correlations (default)
% par.dircorrelation = logical(1) - Direction correlations (scales V to unity)
% par.direction = logical(0) - Use this for true velocities (default)
% par.direction = logical(1) - Use this if the velicities have 180 deg ambiguity
% par.rangebin : Vector that defines the bins in range (r)

% Default parameters
if nargin>2
    if ~isfield(par,'correlation')
        par.correlation = false;
    end
    if ~isfield(par,'direction')
        par.direction = false;
    end
    if ~isfield(par,'rangebin')
        par.rangebin = 1:10;
    end
end


% Memory handling (not in use)
maxN = size(X,2);

% Initialize variables
correlation.direction = par.direction;
correlation.correlation = par.correlation;
correlation.rangebin = par.rangebin;
correlation.phi   = NaN([maxN 1]);
correlation.N     = NaN([maxN 1]);
correlation.meanV = NaN([maxN 2]);
correlation.time  = NaN([maxN 1]);
correlation.Clength = NaN([maxN 1]);
correlation.Ckn = NaN([maxN length(correlation.rangebin)-1]);
correlation.Cn = NaN([maxN length(correlation.rangebin)-1]);

k=1;
% Loop i over frames
for i = 1:size(X,2)
    Xsub = X{i};% Get data for this frame
    if ~isempty(Xsub)
        s.N = size(Xsub,1);
        s.v = Xsub(:,8:9);% Velocity
        s.e = s.v./repmat(sqrt(sum(s.v.^2,2)),[1 2]);% Direction
        if par.correlation % Change to direction correlations
            s.v = s.e;
        end
        % Calculate mean velocity
        s.vm = mean(s.v,1);
        correlation.meanV(k,:) = s.vm;

        s.x = Xsub(:,6:7); % position
        s.d = zeros(s.N); % distance
        % Overall polarization
        correlation.phi(k) = sqrt(sum((1/s.N*sum(s.e,1)).^2));
        % Number of detections
        correlation.N(k) = s.N;
        % Distance between individuals
        s.d = NaN(s.N);
        s.V = NaN([s.N 1]);
        for m=1:s.N
            for n=1:m
                s.d(m,n) = hypot(s.x(m,1)-s.x(n,1), s.x(m,2)-s.x(n,2));
            end
            s.V(m) = hypot(s.v(m,1),s.v(m,2));
        end
        % Remove fluctuation
        s.u = s.v - repmat(s.vm,[s.N 1]);
        
        % Correlation between prey and prey as function of distance
        corr = correlationfunction(s,correlation.rangebin,par);
        correlation.Ckn(k,:) = corr.Ckn;
        correlation.Cn(k,:) = corr.Cn;
        correlation.Clength(k) = corr.CLength;
        
%         if k>=maxN
%             F = fields(correlation);
%             for fn=1:length(F)
%                 str=['correlation.',F{fn},' = [correlation.',F{fn},';NaN(size(correlation.',F{fn},'))];'];
%                 eval(str)
%             end
%             maxN = maxN + maxN;
%         end
        k=k+1;
    end %~isempty(Xsub)
end

% Release and trim memory
correlation.phi     = correlation.phi(1:k-1);
correlation.N       = correlation.N(1:k-1);
correlation.meanV   = correlation.meanV(1:k-1,:);
correlation.Ckn       = correlation.Ckn(1:k-1,:);
correlation.Cn       = correlation.Cn(1:k-1,:);
correlation.Clength = correlation.Clength(1:k-1);
correlation.time    = correlation.time(1:k-1);
correlation.range   = corr.range;

function corrd = correlationfunction(s,R,par)
% Calculate correlations for one frame
%
% Output:
% corrd.Cn       : Number of detections
% corrd.Ckn      : C_kn(r) as defined in SI
% corrd.CLength  : Correlation length based in zero corssing

% Loop over rangebins
for r=1:(length(R)-1)
    % Pick pairs within rangebin
    [i,j] = find( (s.d>R(r)) & (s.d<=R(r+1)));
    if length(i)>2
        mu = hypot(s.u(i,1),s.u(i,2)).*hypot(s.u(j,1),s.u(j,2));
        corrd.Cn(r) = length(i);
        if par.direction % "Remove" 180 deg ambiguity
            corrd.Ckn(r) = sum(abs(s.u(i,1).*s.u(j,1) + s.u(i,2).*s.u(j,2)))/sum(mu);
        else
            corrd.Ckn(r) = sum(s.u(i,1).*s.u(j,1) + s.u(i,2).*s.u(j,2))/sum(mu);
        end
    end
end

% Fit curve for zero crossings
corr_range = 0.5*(R(1:end-1)+R(2:end));

% Increase resolution
splinewm = smooth_spline(corrd.Ckn,corr_range, length(corr_range), .99999);
% Increase resolution and do spline interpolant
corr_range_fine = linspace(corr_range(1),corr_range(end),length(corr_range)*100);
splinewm_fine = interp1(corr_range,splinewm,corr_range_fine,'spline');
% Calculate zero crosssing for the mean of this bin
zerocrossing = corr_range_fine(min((find(0>splinewm_fine)))); %#ok<NASGU>
if isempty(zerocrossing)
    corrd.CLength = NaN;
else
    corrd.CLength = zerocrossing;
end

corrd.range = corr_range;

%  smooth_spline.m
%  Spline smoothing  (DeBoor's algorithm)
%
%   Fred Frigo
%   Dec 8, 2001
%
% Adapted to MATLAB from the following Fortran source file
%    found at http://www.psc.edu/~burkardt/src/splpak/splpak.f90
function spline_sig = smooth_spline( y, dx, npoint, smooth_factor)

p=smooth_factor;
a=[npoint:4];
v=[npoint:7];
a= 0.0;
v= 0.0;


%qty=[npoint:1];
%qu=[npoint:1];
%u=[npoint:1];

x = linspace(0.0, (npoint-1.0)/npoint , npoint);

% setupq
v(1,4) = x(2)-x(1);

for i = 2:npoint-1
    v(i,4) = x(i+1)-x(i);
    v(i,1) = dx(i-1)/v(i-1,4);
    v(i,2) = ((-1.0.*dx(i))/v(i,4)) - (dx(i)/v(i-1,4));
    v(i,3) = dx(i+1)/v(i,4);
end


v(npoint,1) = 0.0;
for i = 2:npoint-1
    v(i,5) = (v(i,1)*v(i,1)) + (v(i,2)*v(i,2)) + (v(i,3)*v(i,3));
end

for i = 3:npoint-1
    v(i-1,6) = (v(i-1,2)*v(i,1)) + (v(i-1,3)*v(i,2));
end

v(npoint-1,6) = 0.0;

for i = 4: npoint-1
    v(i-2,7) = v(i-2,3)*v(i,1);
end

v(npoint-2,7) = 0.0;
v(npoint-1,7) = 0.0;
%!
%!  Construct  q-transp. * y  in  qty.
%!
prev = (y(2)-y(1))/v(1,4);
for i= 2:npoint-1
    diff = (y(i+1)-y(i))/v(i,4);
    %qty(i) = diff-prev;
    a(i,4) = diff - prev;
    prev = diff;
end

% end setupq

%chol1d

%!
%!  Construct 6*(1-p)*q-transp.*(d**2)*q + p*r
%!
six1mp = 6.0.*(1.0-p);
twop = 2.0.*p;

for i = 2: npoint-1
    v(i,1) = (six1mp.*v(i,5)) + (twop.*(v(i-1,4)) + v(i,4));
    v(i,2) = (six1mp.*v(i,6)) +( p.*v(i,4));
    v(i,3) = six1mp.*v(i,7);
end

if ( npoint < 4 )
    u(1) = 0.0;
    u(2) = a(2,4)/v(2,1);
    u(3) = 0.0;
    %!
    %!  Factorization
    %!
else
    for i = 2: npoint-2;
        ratio = v(i,2)/v(i,1);
        v(i+1,1) = v(i+1,1)-(ratio.*v(i,2));
        v(i+1,2) = v(i+1,2)-(ratio.*v(i,3));
        v(i,2) = ratio;
        ratio = v(i,3)./v(i,1);
        v(i+2,1) = v(i+2,1)-(ratio.*v(i,3));
        v(i,3) = ratio;
    end
    %!
    %!  Forward substitution
    %!
    a(1,3) = 0.0;
    v(1,3) = 0.0;
    a(2,3) = a(2,4);
    for i = 2: npoint-2
        a(i+1,3) = a(i+1,4) - (v(i,2)*a(i,3)) - (v(i-1,3)*a(i-1,3));
    end
    %!
    %!  Back substitution.
    %!
    a(npoint,3) = 0.0;
    a(npoint-1,3) = a(npoint-1,3) / v(npoint-1,1);
    
    for i = npoint-2:-1:2
        a(i,3) = (a(i,3)/v(i,1)) - (a(i+1,3)*v(i,2)) - (a(i+2,3)*v(i,3));
    end
    
end
%!
%!  Construct Q*U.
%!
prev = 0.0;
for i = 2: npoint
    a(i,1) = (a(i,3)-a(i-1,3))/v(i-1,4);
    a(i-1,1) = a(i,1)-prev;
    prev = a(i,1);
end

a(npoint,1) = -1.0.*a(npoint,1);

%end chol1d

for i = 1: npoint
    spline_sig(i) = y(i)-(6.0.*(1.0-p).*dx(i).*dx(i).*a(i,1));
end

%  for i = 1: npoint
%    a(i,3) = 6.0*a(i,3)*p;
%  end

%  for i = 1: npoint-1
%    a(i,4) = (a(i+1,3)-a(i,3))/v(i,4);
%    a(i,2) = (a(i+1,1)-a(i,1))/v(i,4)-(a(i,3)+a(i,4)/3.*v(i,4))/2.*v(i,4);
%  end


