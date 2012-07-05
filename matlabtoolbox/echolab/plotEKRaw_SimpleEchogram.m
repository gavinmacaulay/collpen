function h = plotEKRaw_SimpleEchogram(pings, varargin)


if (~isfield(pings, 'number'))
    warning('plotEKRaw:BadParameter', ['Incorrect or malformed ''pings'' ' ...
        'data structure.']);
    return;
end

threshold = [-70 -34];          %  default display thresholds
doRGB = false;
fig = [];                       %  no figure handle default is to create new
figPosition = [];               %  no figure position defined use default
mode = uint8(0);                %  display echogram by default
xRange = [];                    %  by default plot all pings
yRange = [];                    %  by default plot all samples
dataRGB = [];                   %  default is to use the "simrad" colortable
%mask = [];
maskIDs = [];
visible = 'on';

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'echogram'
            mode = uint8(0);
        case 'anglogram'
            mode = uint8(1);
        case 'threshold'
            threshold = varargin{n+1};
        case 'figure'
            fig = varargin{n+1};
        case 'mask'
            mask = varargin{n+1};
        case 'plotmaskids'
            maskIDs = varargin{n+1};
        case 'position'
            figPosition = varargin{n+1};
        case 'colormap'
            dataRGB = varargin{n+1};
        case 'visible'
            visible = varargin{n+1};
        case 'xrange'
            xRange = varargin{n+1};
        case 'yrange'
            yRange = varargin{n+1};
        case 'dorgb'
            doRGB = varargin{n+1};
        otherwise
    end
end

%  define a default figure size/position
if (isempty(figPosition))
    scSize = get(0, 'MonitorPosition');
    figPosition = [(scSize(1,3) * 0.1) (scSize(1,4) * 0.25) ...
        (scSize(1,3) * 0.8) (scSize(1,4) * 0.5)];
end

% define default ranges
if (isempty(xRange)); xRange = [min(pings.number) max(pings.number)]; end
if (isempty(yRange)); yRange = [0, max(pings.range)]; end

%  create (or raise) a figure window
if (~isempty(fig))
    %  apply position to new figure only
    if (ishandle(fig))
        %  existing figure - simply raise it
        h.figure = figure(fig);
    else
        %  new figure, create and define position
        h.figure = figure(fig, 'Position', figPosition, 'Visible', visible);
    end
else
    %  new figure, create and define position
    h.figure = figure('Position', figPosition, 'Visible', visible);
end


%  create an axes - reverse the y axes direction
h.axes = axes('YDir', 'reverse', 'Ylim', yRange, ...
    'XLim', xRange);

if (mode == 0)
    %  plot the echogram into the current axes
    if (isfield(pings, 'Sv'))
        egHandles = plotEKRaw_MakeEchogram(pings.Sv, 'yData', pings.range, ...
            'Threshold', threshold, 'ShowColorbar', true, 'YRange', yRange, ...
            'Colormap', dataRGB, 'Mask', mask, 'MaskIDs', maskIDs, ...
            'xRange', xRange, 'xData', pings.number, 'doRGB', doRGB);
    else
        egHandles = plotEKRaw_MakeEchogram(pings.sv, 'yData', pings.range, ...
            'Threshold', threshold, 'ShowColorbar', true, 'YRange', yRange, ...
            'Colormap', dataRGB, 'Mask', mask, 'MaskIDs', maskIDs, ...
            'lin2db', true, 'xRange', xRange, 'xData', pings.number);
    end
    h.colorbar = egHandles.colorbar;
else
    %  plot the anglogram into the current axes
    egHandles = plotEKRaw_MakeEchogram(pings.alongship, pings.athwartship, ...
        'yData', pings.range, 'Anglogram', true);
    
end

% %  adjust X axis text label properties
% xTicks = get(h.axes, 'Xtick');
% 
% %xTickLabel = get(h.axes, 


%  copy the component handles
if (isfield(egHandles, 'legend')); h.legend = egHandles.legend; end
h.image = egHandles.image;
h.xRange =  xRange;
h.yRange =  yRange;