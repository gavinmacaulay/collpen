function out = processEKRaw_EchoIntegrate(data, mask, calParms, cells, varargin)

global EKMASKBITS

%  threshold modes are:
%    0 - threshold none
%    1 - threshold low
%    2 - threshold high
%    3 threshold both low and high

if (~isfield(data.pings, 'sv'))
    error(['processEKRaw_EchoIntegrate requires the volume backscatter ' ...
        'coefficient field "sv".  Set the "linear" parameter to true ' ...
        'when calling readEKRaw_Power2Sv']);
end

%  suppress log of zero error - store previous state
warnState = warning('off', 'MATLAB:log:logOfZero');

%  set default values
threshold = 0;          %  default to no thresholding
rRange = 0;             %  do not return depth at center of cell
rGPS = 0;               %  do not return mean location of interval
rSpeed = 0;             %  do not return mean/sd vessel speed of interval
outType = 'double';     %  default to double precision
regionID = -1;

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'threshold'
            %  0-none  1-low only   2-high only  3-both
            threshold = varargin{n + 1};
        case 'gps'
            rGPS = 0 < varargin{n + 1};
        case 'speed'
            rSpeed = 0 < varargin{n + 1};
        case 'range'
            rRange = 0 < varargin{n + 1};
        case 'regionid'
            regionID = varargin{n + 1};
        otherwise
            warning(['Unknown property name: ' varargin{n}]);
    end
end

%  Create output arrays
nullVal = cast(-999.0, outType);
%  repmat can't handle specifying dimensions in int/uint so convert to double
nLayers = double(cells.nLayers);
nIntervals = double(cells.nIntervals);
out = struct('NASC', zeros(cells.nLayers, cells.nIntervals, outType), ...
             'ABC', zeros(cells.nLayers, cells.nIntervals, outType), ...
             'SvMin', repmat(nullVal, nLayers, nIntervals), ...
             'SvMean', repmat(nullVal, nLayers, nIntervals), ...
             'SvMax', repmat(nullVal, nLayers, nIntervals), ...
             'nSamples', zeros(cells.nLayers, cells.nIntervals, outType), ...
             'meanThickness', zeros(cells.nLayers, cells.nIntervals, outType), ...
             'TotalSamples', zeros(cells.nLayers, cells.nIntervals, outType));
if (rRange); out.range = zeros(cells.nLayers, cells.nIntervals, outType); end
if (rGPS)
    out.gps.lat = zeros(1, cells.nIntervals, outType);
    out.gps.lon = zeros(1, cells.nIntervals, outType);
end
if (rSpeed)
    out.speed.mean = zeros(1, cells.nIntervals, outType);
    out.speed.std = zeros(1, cells.nIntervals, outType);
end

%  calculate sample thickness
dR = calParms.soundvelocity * calParms.sampleinterval / 2;

%  process each region
for m = 1:cells.nIntervals
    for n = 1:cells.nLayers

        %  extract subsets of data
        subMask = mask(cells.layerBins == n, cells.intervalBins == m);
        subsv = data.pings.sv(cells.layerBins == n, cells.intervalBins == m);
        samplesInRegion = bitget(subMask, EKMASKBITS.inRegion);
        if (regionID > 0)
            samplesInRegion = samplesInRegion & ...
                bitget(subMask, regionID);
        end
        nSamplesInRegion = sum(sum(samplesInRegion));
        out.TotalSamples(n,m) = nSamplesInRegion;
        
        %  create "good" sample mask
        goodSamples = logical(bitget(subMask, EKMASKBITS.valid));
        if (regionID > 0)
            goodSamples = goodSamples & ...
                bitget(subMask, regionID);
        end
        
        %  calculate sample volume
        sVol = sum(sum(goodSamples));
        if (sVol == 0); continue; end

        %  create bitmask of samples to include in integration        
        switch threshold
            case 0
                %  include all samples
                iIdx = goodSamples;
            case 1
                %  exclude samples below min threshold
                iIdx = goodSamples & ...
                    bitget(subMask, EKMASKBITS.thresholdLow);
            case 2
                %  exclude samples above max threshold
                iIdx = goodSamples & ...
                    bitget(subMask, EKMASKBITS.thresholdHigh);
            case 3
                %  exclude samples below min AND above max threshold
                iIdx = goodSamples & ...
                    bitget(subMask, EKMASKBITS.thresholdLow) & ...
                    bitget(subMask, EKMASKBITS.thresholdHigh);
        end
        %  continue if no samples are included
        if (any(iIdx) == 0); continue; end

        %  calculate mean thickness of region
        pThick = sum(goodSamples, 1) * dR;
        mean_thick = sum(pThick) / sum(pThick > 0);
        mean_thick_samp = mean_thick / dR;

        %  calculate mean sv
        sv_mean = sum(subsv(iIdx)) / sVol;

        %  calculate the rest...
        out.ABC(n,m) = sv_mean * mean_thick;
        out.NASC(n,m) = out.ABC(n,m) * pi * 13719616;
        out.SvMean(n,m) = 10 * log10(sv_mean);
        out.SvMin(n,m) = 10 * log10(min(subsv(iIdx)));
        out.SvMax(n,m) = 10 * log10(max(subsv(iIdx)));
        out.nSamples(n,m) = sVol;
        out.meanThickness(n,m) = mean_thick_samp;
        
        if (rRange)
            %  calculate mean depth of cell 
            out.range(n,m) = mean(data.pings.range(cells.layerBins == n));
        end
        
    end

    if (rGPS)
        %  calculate averaged GPS locations for intervals
        out.gps.lat(m) = mean(data.gps.lat(cells.intervalBins == m));
        out.gps.lon(m) = mean(data.gps.lon(cells.intervalBins == m));
    end
    if (rSpeed)
        %  calculate vessel speed mean and standard deviation
        vs = data.gps.vspeed(cells.intervalBins == m);
        vs = vs(~isnan(vs));
        out.speed.mean(m) = mean(vs);
        out.speed.std(m) = std(vs);
    end

end

%  restore warning state
warning(warnState);


