function y = perform_atrou_transform(x,Jmin,options)

% perform_atrou_transform - compute the "a trou" wavelet transform, 
%   i.e. without subsampling.
%
%   w_list = perform_atrou_transform(M,Jmin,options);
%
%   'w_list' is a cell array, w_list{ 3*(j-Jmin)+q }
%   is an imagette of same size as M containing the full transform
%   at scale j and quadrant q.
%   The lowest resolution image is in w_list{3*(Jmax-Jmin)+4} =
%   w_list{end}.
%
%   The ordering is :
%       { H_j,V_j,D_j, H_{j-1},V_{j-1},D_{j-1}, ..., H_1,V_1,D_1, C }
%
%   'options' is an (optional) structure that may contains:
%       options.wavelet_type: kind of wavelet used (see perform_wavelet_transform)
%       options.wavelet_vm: the number of vanishing moments of the wavelet transform.
%
%	When possible, this code tries to use the following fast mex implementation:
%		* Rice Wavelet Toolbox : for Daubechies filters, ie when options.wavelet_type='daubechies'.
%		Only the Windows binaries are included, please refer to 
%			http://www-dsp.rice.edu/software/rwt.shtml
%		to install on other OS.
%
%   Copyright (c) 2006 Gabriel Peyré


% add let it wave a trou transform to the path
% path('./cwpt2/',path);
% add Rice Wavelet Toolbox transform to the path
% path('./rwt/',path);

if nargin<3
    options.null = 0;
end

if isfield(options, 'wavelet_type') 
    wavelet_type = options.wavelet_type;
    wavelet_vm = 4;
else
    wavelet_type = 'biorthogonal';
    wavelet_vm = 3;
end

if isfield(options, 'wavelet_vm')   
    wavelet_vm = options.wavelet_vm;
end

if isfield(options, 'bound')
    bound = options.bound;
else
    bound = 'sym';
end

% first check for LIW interface, since it's the best code
if exist('cwpt2_interface') && ~strcmp(wavelet_type, 'daubechies') &&  ~strcmp(wavelet_type, 'symmlet')
    
    if  strcmp(wavelet_type, 'biorthogonal') || strcmp(wavelet_type, 'biorthogonal_swapped')
        if wavelet_vm~=3
            warning('Works only for 7-9 wavelets.');
        end
        wavelet_types = '7-9';
    elseif strcmp(wavelet_type, 'battle')
        if wavelet_vm~=3
            warning('Works only for cubic spline wavelets.');
        end
        wavelet_types = 'spline';
    else
        error('Unknown transform.');
    end
    
    if isfield(options, 'decomp_type')
        decomp_type = options.decomp_type;
    else
        decomp_type = 'quad';   % either 'quad' or 'tri'
    end
    
    if ~iscell(x)
        dirs = 'forward';
        J = log2(size(x,1)) - Jmin;
        M = x;
    else
        dirs = 'inverse';
        if strcmp(decomp_type, 'tri')
            x = { x{1:end-3}, x{end}, x{end-2:end-1} };
        else
            x = { x{1:end-4}, x{end}, x{end-3:end-1} };
        end
        J = 0;
        M = zeros(size(x{1},1), size(x{1},2), J);
        for i=1:length(x)
            M(:,:,i) = x{i};
        end
    end
    
    y = cwpt2_interface(M, dirs, wavelet_types, decomp_type, J);
    
    if ~iscell(x)
       M = y; y = {};
       for i=1:size(M,3)
           y{i} = M(:,:,i);
       end
       % put low frequency at the end
       if strcmp(decomp_type, 'tri')
           y = { y{1:end-3}, y{end-1:end}, y{end-2} };
       else
           y = { y{1:end-4}, y{end-2:end}, y{end-3} };
       end
    end
    return;
end

% precompute filters
if strcmp(wavelet_type, 'daubechies')
    qmf = MakeONFilter('Daubechies',wavelet_vm*2);  % in Wavelab, 2nd argument is VM*2 for Daubechies... no comment ...
elseif strcmp(wavelet_type, 'symmlet')
    qmf = MakeONFilter('Symmlet',wavelet_vm);
elseif strcmp(wavelet_type, 'battle')
    qmf = MakeONFilter('Battle',wavelet_vm-1);
elseif strcmp(wavelet_type, 'biorthogonal')
    [qmf,dqmf] = MakeBSFilter( 'CDF', [wavelet_vm,wavelet_vm] );
elseif strcmp(wavelet_type, 'biorthogonal_swapped')
    [dqmf,qmf] = MakeBSFilter( 'CDF', [wavelet_vm,wavelet_vm] );
else
    error('Unknown transform.');
end

g = qmf;                % for phi
h = mirror_filter(g);    % for psi

% for reconstruction
gg = g;
hh = g;
if exist('dqmf')
    gg = dqmf;
    hh = mirror_filter(gg);
end


if exist('mirdwt') & exist('mrdwt') & strcmp(wavelet_type, 'daubechies')
    %%% USING RWT %%%
    if ~iscell(x)
        n = length(x);
        Jmax = log2(n)-1;
        %%% FORWARD TRANSFORM %%%
        L = Jmax-Jmin+1;
        [yl,yh,L] = mrdwt(x,g,L);
        for j=Jmax:-1:Jmin
            for q=1:3
                s = 3*(Jmax-j)+q-1;
                M = yh(:,s*n+1:(s+1)*n); 
                y{ 3*(j-Jmin)+q } = M;
            end
        end
        y{ 3*(Jmax-Jmin)+4 } = yl;         
    else
        n = length(x{1});
        Jmax = log2(n)-1;
        %%% BACKWARD TRANSFORM %%%
        L = Jmax-Jmin+1;
        if L ~= (length(x)-1)/3
            warning('Jmin is not correct.');
            L = (length(x)-1)/3;
        end
        yl = x{ 3*(Jmax-Jmin)+4 }; 
        yh = zeros( n,3*L*n );
        for j=Jmax:-1:Jmin
            for q=1:3
                s = 3*(Jmax-j)+q-1;
                yh(:,s*n+1:(s+1)*n) = x{ 3*(j-Jmin)+q };
            end
        end
        [y,L] = mirdwt(yl,yh,gg,L);
    end
    return;
end

n = length(x);
Jmax = log2(n)-1;
if iscell(x)
    error('reverse transform is not yet implemented.');    
end
M = x;


Mj = M;     % image at current scale (low pass filtered)

nh = length(h);
ng = length(g);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the transform 
wb = waitbar(0,'Computing a trou transform.');
for j=Jmax:-1:Jmin
    waitbar((Jmax-j)/(Jmax-Jmin),wb);
    
    % 1st put some zeros in between g and h
    nz = 2^(Jmax-j);    % space between coefs
    hj = zeros(nz*(nh-1)+1, 1);
    gj = zeros(nz*(ng-1)+1, 1);
    hj( 1 + (0:nh-1)*nz ) = h;
    gj( 1 + (0:ng-1)*nz ) = g;
    
    %%%% filter on X %%%%
    Mjh = zeros(n,n);
    Mjg = zeros(n,n);
    for i=1:n
        Mjh(:,i) = perform_convolution( Mj(:,i), hj, bound );
        Mjg(:,i) = perform_convolution( Mj(:,i), gj, bound );
    end
    
    %%%% filter on Y %%%%
    Mjhh = zeros(n,n);
    Mjhg = zeros(n,n);
    Mjgh = zeros(n,n);
    Mjgg = zeros(n,n);
    for i=1:n
        Mjhh(i,:) = perform_convolution( Mjh(i,:)', hj, bound )';
        Mjhg(i,:) = perform_convolution( Mjh(i,:)', gj, bound )';
        
        Mjgh(i,:) = perform_convolution( Mjg(i,:)', hj, bound )';
        Mjgg(i,:) = perform_convolution( Mjg(i,:)', gj, bound )';
    end
    
    Mj = Mjgg;
    w_list{ 3*(j-Jmin)+1 } = Mjgh;
    w_list{ 3*(j-Jmin)+2 } = Mjhg;
    w_list{ 3*(j-Jmin)+3 } = Mjhh;
    
end
close(wb);

w_list{ 3*(Jmax-Jmin)+4 } = Mj;

y = w_list;