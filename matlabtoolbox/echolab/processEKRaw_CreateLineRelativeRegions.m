function mask = processEKRaw_CreateLineRelativeRegions(rawData, mask, calParms, ...
    line, regionBounds, inverse)

%  regions can be a scalar or vector - positive shallower, negative is deeper


global EKMASKBITS

%  calculate sample thickness
hdR = calParms(1).soundvelocity * calParms(1).sampleinterval / 4;

%  determine number of regions
nRegions = length(regionBounds) - 1;
if (nRegions > 20); error('Maximum 20 line relative regions allowed'); end

%  sort so we're always working from bottom up
regionBounds = sort(regionBounds);
rb = zeros(2,1);

for n=1:nRegions
    %  determine the boundaries for this region
    rb(1) = line - regionBounds(n);
    rb(2) = line - regionBounds(n + 1);
    if (rb(2) < 0); break; end
    
    %  mask individual line relative regions
    luIdx = find(((rawData.pings.range + hdR) - rb(2)) > 0, 1, 'first');
    llIdx = find(((rawData.pings.range - hdR) - rb(1)) <= 0, 1, 'last');
    if (inverse)
        mask(1:luIdx) = bitset(mask(1:luIdx), EKMASKBITS.valid, 0);
        mask(1:luIdx) = bitset(mask(1:luIdx), EKMASKBITS.inRegion, 0);
        mask(llIdx:end) = bitset(mask(llIdx:end), EKMASKBITS.valid, 0);
        mask(llIdx:end) = bitset(mask(llIdx:end), EKMASKBITS.inRegion, 0);
    else
        mask(luIdx:llIdx) = bitset(mask(luIdx:llIdx), n, 1);
    end
end