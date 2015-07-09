function y = perform_pyramid_transform_simoncelli(x, Jmin,options)

% perform_pyramid_transform_simoncelli - Laplacian pyramidal transform
%
%   y = perform_pyramid_transform_simoncelli(x, Jmin);
%
%   This is just a convenient wrapper to the original steerable 
%   matlab toolbox of Simoncelli that can be downloaded from
%       http://www.cns.nyu.edu/~eero/STEERPYR/
%
%   It provide a simpler interface that directly output a cell
%   array of images. Usage :
%
%   M = load_image('lena');
%   MS = perform_pyramid_transform_simoncelli(M, 3); % synthesis
%   M1 = perform_pyramid_transform_simoncelli(MS);   % reconstruction
%   
%   Copyright (c) 2005 Gabriel Peyré

if nargin<3
    options.null = 0;
end

filts = 'binom5';

if ~iscell(x)
    if nargin<2
        Jmin = 4;
    end
    Jmax = log2(size(x,1))-1;
    nbr_bands = Jmax - Jmin + 1;
    % fwd transform
    [pyr,pind] = buildLpyr(x, nbr_bands, filts, filts, 'reflect1');
    % copy into cell array    
    y = {};
    for k=1:size(pind, 1)
        indices =  pyrBandIndices(pind,k);
        L = length(indices);    % length of this scale
        y{k} = reshape( pyr(indices), sqrt(L), sqrt(L) );
    end
else
    n = size(x{1},1);
    Jmax = log2(n)-1;
    nbr_bands = length(x);
    % copy from cell array
    pind = n ./ 2.^(0:nbr_bands-1);
    pind = [pind(:), pind(:)];
    % build the matrix
    n = sum( prod(pind,2) );
    pyr = zeros(n, 1);
    for k=1:size(pind, 1)
        indices =  pyrBandIndices(pind,k);
        L = length(indices);    % length of this scale
        pyr(indices) = x{k}(:);
    end
    % bwd transform
    y = reconLpyr(pyr, pind, 'all', filts); 
end