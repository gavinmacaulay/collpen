function y = perform_steerable_transform(x, Jmin,options)

% perform_steerable_transform - steerable pyramidal transform
%
%   y = perform_steerable_transform(x, Jmin,options);
%
%   This is just a convenient wrapper to the original steerable 
%   matlab toolbox of Simoncelli that can be downloaded from
%       http://www.cns.nyu.edu/~eero/STEERPYR/
%
%   It provide a simpler interface that directly output a cell
%   array of images. Usage :
%
%   M = load_image('lena');
%   MS = perform_steerable_transform(M, 3); % synthesis
%   M1 = perform_steerable_transform(MS);   % reconstruction
%
%   options.nb_orientations : number of orientation of the pyramid (1/2/4/6)
%   
%   Copyright (c) 2005 Gabriel Peyré

if nargin<3
    options.null = 0;
end
if nargin<2
    Jmin = 4;
end

if isfield(options, 'nb_orientations')
    nb_orientations = options.nb_orientations;
else
    nb_orientations = 4;    % can be 1/2/4/6
end

if nb_orientations~=1 && nb_orientations~=2 && nb_orientations~=4 && nb_orientations~=6
    error('The number of orientation should be 1,2,4 or 6.');
end


filts =  ['sp' num2str(nb_orientations-1) 'Filters'];

if ~iscell(x)
    Jmax = log2(size(x,1))-1;
    if Jmax-Jmin+1>5
        warning('Cannot construct pyramid higher than 5 levels');
        Jmin = Jmax-4;
    end
    nbr_bands = Jmax - Jmin + 1;
    % fwd transform
    [pyr,pind] = buildSpyr(x, nbr_bands, filts);
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
    nbr_bands = Jmax - Jmin + 1;
    % copy from cell array
    pind = n ./ 2.^(0:nbr_bands-1);
    pind = repmat(pind, nb_orientations, 1);
    pind = [pind(:), pind(:)];
    pind = [pind(1,:); pind];
    pind = [pind; pind(end,:)/2];
    % build the matrix
    n = sum( prod(pind,2) );
    pyr = zeros(n, 1);
    for k=1:size(pind, 1)
        indices =  pyrBandIndices(pind,k);
        L = length(indices);    % length of this scale
        pyr(indices) = x{k}(:);
    end
    % bwd transform
    y = reconSpyr(pyr, pind, filts); 
end

youhou = 1;

