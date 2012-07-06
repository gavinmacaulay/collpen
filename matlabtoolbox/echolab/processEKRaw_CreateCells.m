function out = processEKRaw_CreateCells(data, varargin)
%processEKRaw_CreateCells  Create analysis cells
%   cellStruct = processEKRaw_CreateCells(data) returns a structure defining an
%   analysis grid which can be passed to the echoIntegrate function.
%
%   REQUIRED INPUT:
%       data:       echolab data structure containing the following fields:
%                       gps
%                       range
%
%   OPTIONAL PARAMETERS:
%             Interval: Set to a scalar value defining the interval length in nmi
%                           Default: 0.5 nmi
%
%                Layer: Set to a scalar value defining the layer size in meters.
%                           Default: 10m
%
%               Layers: Set to a vector defining the layer boundaries.  Useful
%                       for when you need non-uniformly spaced layer boundaries.
%                       The vector must be of length nLayers+1 with a minimum of
%                       2 values defining the top and bottom of one layer.
%                       When this parameter is set, the "Layer", "LayerStart" and
%                       "LayerEnd" parameters are ignored.
%                       Set to -1 to use automatic uniform boundaries.
%                           Default: -1
%
%             LayerEnd: Set to a scalar defining the maximum range of the layers
%                       relative to the surface.  Layers are created down to and
%                       including this range.
%                           Default: max(data.ping.range)
%
%           LayerStart: Set to a scalar defining the initial layer depth,
%                       relative to the surface.
%                           Default: 0m
%
%        IntervalStart: Set to a scalar value defining the interval starting
%                       point in nmi traveled.  Set to -1 to start the first
%                       interval at the first ping.
%                           Default: -1
%
%          IntervalEnd: Set to a scalar value defining the interval ending point
%                       in nmi traveled.  Set to -1 to end the last interval at
%                       the last ping.
%                           Default: -1
%
%              Segment: Set to a scalar value defining the transect segement to
%                       create the analysis cells for.  Set to -1 to ignore
%                       segment information.
%                           Default: -1
%
% StrictIntervalLength: Set to true to enforce strict horizontal interval
%                       lengths.  Any orphaned pings (pings outside the last full 
%                       interval) will not be binned.
%                           Default: True
%
%   OUTPUT:
%       Output is a data structure with the following fields:
%
%       intervals:      vector of interval boundaries (in nmi traveled)
%       nIntervals:     number of elements in intervals
%       intervalBins:   vector of length nPings containing the interval #
%                       that ping belongs to.
%       nPingsInInt:    vector of length nIntervals containing the number of
%                       pings per interval.
%       intervalGrid:   location of grid boundaries (in pings).
%       layers:         vector of layer boundaries (in m)
%       nLayers:        number of elements in layers
%       layerBins:      vector of length nSamples containing the layer #
%                       that sample belongs to.
%       nSampsInLayer:  vector of length nLayers containing the number of
%                       pings per layer.
%       layerGrid:      location of layer boundaries (in samples).
%
%   REQUIRES:
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  check that our data contains required fields
if (~isfield(data.pings, 'range'))
    message('processEKRaw:Parameter Error', ['Echodata structure must ' ...
        'contain the pings.range structure field']);
end
if (~isfield(data, 'gps'))
    message('processEKRaw:Parameter Error', ['Echodata structure must ' ...
        'contain the gps structure field']);
end

%  define default parameters
hInt = 0.5;                         %  horizontal interval (nmi)
intervalStart = -1;                 %  horiz intervals start at first ping (nmi)
intervalEnd = -1;                   %  horiz intervals end at last ping (nmi)
vInt = 10;                          %  vertical interval (layer depth) in m
layerStart = 0;                     %  layers start at range 0 (m)
layerEnd = max(data.pings.range);   %  layers end at last sample (m)
segment = -1;
strict = 1;                         %  default to strict horizontal interval lengths
layers = -1;                        %  explicit layers not defined

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'interval'
            hInt = varargin{n + 1};
        case 'layer'
            vInt = varargin{n + 1};
        case 'layers'
        	if (length(varargin{n + 1}) > 1)
                layers = varargin{n + 1};
            else
                warning('processEKRaw:ParameterError', ...
                    'Layers parameter must contain at least 2 values');
            end
        case 'intervalstart'
            intervalStart = varargin{n + 1};
        case 'intervalend'
            intervalEnd = varargin{n + 1};
        case 'layerstart'
            layerStart = varargin{n + 1};
        case 'layerend'
            layerEnd = varargin{n + 1};
        case 'segment'
            segment = varargin{n + 1};
        case 'strictintervallength'
            strict = 0 < varargin{n + 1};
        otherwise
            warning('processEKRaw:ParameterError', ['Unknown property name: ' ...
                varargin{n}]);
    end
end

%  define interval starting and ending points
if (segment > 0)
    %  interval beginning and ending within segment
    if (intervalStart < 0)
        intervalStart = min(data.gps.cdist(data.pings.seg == segment));
    end
    if (intervalEnd < 0)
        intervalEnd = max(data.gps.cdist(data.pings.seg == segment));
    end
else
    %  interval beginning and ending covers entire data set
    if (intervalStart < 0); intervalStart = data.gps.cdist(1); end
    if (intervalEnd < 0); intervalEnd = data.gps.cdist(end); end
end


%  create output structure
out = struct('intervals', 0, ...
             'nIntervals', uint16(0), ...
             'intervalBins', 0, ...
             'nPingsInInt', uint16(0), ...
             'intervalGrid', 0, ...
             'layers', 0, ...
             'nLayers', uint16(0), ...
             'layerBins', 0, ...
             'nSampsInLayer', uint16(0), ...
             'layerGrid', 0);

%  set up vertical intervals (layers)       
if (mod(layerEnd - layerStart, vInt) > 0)
    %  extend layer range to encompass last partial layer
    layerEnd = layerEnd + vInt;
end

%  create layer vector
if (length(layers) > 1)
     out.layers = layers;
else
    out.layers = (layerStart:vInt:layerEnd)';
end

%  determine number of layers
out.nLayers = uint16(length(out.layers) - 1);

%  sort samples into bins
[nSampsInLayer, layerBins] = histc(data.pings.range, out.layers);
nSampsInLayer = nSampsInLayer(nSampsInLayer > 0);
%layerBins = layerBins(layerBins > 0);   %  this line breaks "layers" functionality
out.layerGrid = uint16(unique([find(layerBins==1, 1, 'first') ...
    (find(diff(layerBins)) + 1)']));
out.layerBins = uint16(layerBins);
out.nSampsInLayer = uint16(nSampsInLayer);


%  set up horizontal intervals
if (~strict) && (mod(intervalEnd - intervalStart, hInt) > 0)
    %  extend interval range to encompass last partial interval
    intervalEnd = intervalEnd + hInt;
end

%  create interval vector
out.intervals = (intervalStart:hInt:intervalEnd)';

%  determine number of intervals
out.nIntervals = uint16(length(out.intervals) - 1);

%  sort pings into bins
if (segment > 0)
    [nPingsInInt, intervalBins] = histc(data.gps.cdist(data.pings.seg == segment), ...
        out.intervals);
else
    [nPingsInInt, intervalBins] = histc(data.gps.cdist, out.intervals);
end
nPingsInInt = nPingsInInt(nPingsInInt > 0);
intervalBins = intervalBins(intervalBins > 0);
out.intervalGrid = uint16([1 cumsum(nPingsInInt)' + 1]);
out.intervalBins = uint16(intervalBins);
out.nPingsInInt = uint16(nPingsInInt);
    

    
    