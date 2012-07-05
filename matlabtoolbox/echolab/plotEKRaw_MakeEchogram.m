
function h = plotEKRaw_MakeEchogram(data, varargin)

%  this is a hack - define a color table for filter results
maskMap = [12 44 132; ...
           204 76 2; ...
           122 1 119; ...
           102 189 99; ...
           153 0 10; ...
           140 81 10; ...
           80 80 80];
markMap = maskMap / 255;
maskMap = uint8(maskMap);


%  get the mask id's if available
global EKMASKBITS
if (isstruct(EKMASKBITS)); fNames = flipud(fieldnames(EKMASKBITS)); end

%  set default values
eThreshold = [-70 -34];                 %  default echogram thresholds
aThreshold = [-12 12];                  %  default anglogram thresholds
dataRGB = ek500(0);                     %  default "Simrad" echogram color table
maskRGB = colormap(colorcube(32));      %  default mask colormap
doRGB = false;                          %  default is *not* to convert echogram to RGB
parent = [];                            %  default is to use current axes as parent
xData = [];                             %  default is to generate x data vector
yData = [];                             %  default is to generate y data vector
xRange = [];                            %  default is to plot all pings
yRange = [];                            %  default is to plot all samples
mask = [];                              %  default - no mask data
maskIDs = [];                           %  default - no mask ID's
showCB = false;
dataAthw = [];
lin2db = false;

%  internal state parameters
setThresh = false;

%  check if 2nd anglogram parameter was passed
nVarArgs = length(varargin);
vaStart = 1;
mode = uint8(0);
if (mod(nVarArgs,2) ~= 0)
    %  additional angles parameter passed - assume anglogram mode
    dataAthw = varargin{1};
    vaStart = 2;
    mode = uint8(1);
end

%  process property name/value pairs
for n = vaStart:2:nVarArgs
    switch lower(varargin{n})
        case 'dorgb'
            doRGB = varargin{n+1} > 0;
        case 'parent'
            parent = varargin{n+1};
        case 'lin2db'
            lin2db = varargin{n+1} > 0;
        case 'mask'
            mask = varargin{n+1};
        case 'maskids'
            maskIDs = varargin{n+1};
        case 'colormap'
            if (~isempty(varargin{n+1}))
                dataRGB = varargin{n+1};
            end
        case 'showcolorbar'
            showCB = varargin{n+1} > 0;
        case 'maskcolortable'
            maskRGB = varargin{n+1};
        case 'threshold'
            threshold = varargin{n+1};
            setThresh = true;
        case 'xrange'
            xRange = varargin{n+1};
        case 'yrange'
            yRange = varargin{n+1};
        case 'xdata'
            xData = varargin{n+1};
        case 'ydata'
            yData = varargin{n+1};
        otherwise
    end
end

clear('varargin');

if (isempty(parent)); parent = gca; end
figHandle = get(parent, 'Parent');
if (~isempty(mask))
    if (isempty(maskIDs)); maskIDs = [1:29]; end
    nFilterIDs = length(maskIDs);
    doRGB = true;
end

%  create data subscripts
if (isempty(xRange) && isempty(xData))
    xiRange = [1 size(data,2)];
    xData = 1:xiRange(2);
elseif (~isempty(xRange) && isempty(xData))
    xData = 1:size(data,2);
    xiRange(1) = find(xRange(1) <= xData, 1, 'first');
    xiRange(2) = find(xRange(2) <= xData, 1, 'first');
else
    xiRange(1) = find(xRange(1) <= xData, 1, 'first');
    xiRange(2) = find(xRange(2) <= xData, 1, 'first');
    xData = xData(xiRange(1):xiRange(2));
end
if (isempty(yRange) && isempty(yData))
    yiRange = [1 size(data,1)];
    yData = 1:yiRange(2);
elseif (~isempty(yRange) && isempty(yData))
    yData = 1:size(data,1);
    yiRange(1) = find(yRange(1) <= yData, 1, 'first');
    yiRange(2) = find(yRange(2) <= yData, 1, 'first');
else
    yiRange(1) = find(yRange(1) <= yData, 1, 'first');
    if (yRange(2) > max(yData)); yRange(2) = max(yData) - 0.01; end
    yiRange(2) = find(yRange(2) <= yData, 1, 'first');
    yData = yData(yiRange(1):yiRange(2));
end

%  extract subscripted data
data = data(yiRange(1):yiRange(2), xiRange(1):xiRange(2));
if (lin2db);
    data(data == 0) = 1e-100;
    data =  10 * log10(data);
end
if (~isempty(dataAthw));
    dataAthw = dataAthw(yiRange(1):yiRange(2), xiRange(1):xiRange(2)); end

%  determine if there are missing pings and fill holes - required for image()
datSize = size(data);
xdiff = diff(xData);
if (max(xdiff) > 1)
    if (mode == 0);
        fillVal = -1000;
    else
        fillVal = 0;
    end
    cidx = xData - (xData(1) - 1);
    data(:,cidx) = data;
    datSize = size(data);
    fidx = 1:datSize(2);
    fidx(cidx) = 0;
    fidx = fidx > 0;
    data(:, fidx) = fillVal;
    if (mode == 1)
        dataAthw(:,cidx) = dataAthw;
        dataAthw(:, fidx) = fillVal;
    end
end

%  prepare input data depending on display mode
switch mode
    case 0
        %  echogram display mode
        
        %  set user defined threshold
        if (setThresh); eThreshold = threshold; end

        %  calculate scaling endpoints
        ctBot = 1;
        ctTop = length(dataRGB);
   
        %  scale and convert to byte for echogram display (zero indexed)
        ctRng = ctTop - ctBot;
        data = uint8(ceil((data - eThreshold(1)) / (eThreshold(2) - ...
            eThreshold(1)) * ctRng) + ctBot);
        
        if (doRGB)
            % 8-bit images are 0 indexed - shift by 1
            data = data + 1;
            data(data > ctTop) = ctTop;
            
            %  convert to 32bit truecolor image
            data32 = zeros([datSize,3], 'uint8');
            data32(:,:,1) = reshape(round(dataRGB(data,1) * 255), datSize);
            data32(:,:,2) = reshape(round(dataRGB(data,2) * 255), datSize);
            data32(:,:,3) = reshape(round(dataRGB(data,3) * 255), datSize);
            data = data32;
            data32 = [];
        end
    case 1
        %  anglogram display mode
        
        %  set user defined threshold
        if (setThresh); aThreshold = threshold; end
        
        %  convert to 32bit truecolor image
        data32 = zeros(datSize(1), datSize(2), 3);
        data32(:,:,1) = (data - aThreshold(1)) / ...
            (aThreshold(2) - aThreshold(1));
        data32(:,:,3) = (dataAthw - aThreshold(1)) / ...
            (aThreshold(2) - aThreshold(1));
        data = data32;
        data32 = [];
        
end


if (~isempty(mask))
    
    %  extract subset of mask data
    mask = mask(yiRange(1):yiRange(2), xiRange(1):xiRange(2));

    %  expand mask if needed
    if (max(xdiff) > 1)
        mask(:,cidx) = mask;
        mask(:, fidx) = 0;
    end
    
    %  compose mask and mask legend
    lHandles = [];
    lText = {};

    %  create a hidden axes for the plot symbols
    hiddenAxes = axes('Visible', 'off', 'HandleVisibility', 'off');

    %  create the default color table
%     mm = uint8(colormap(colorcube(32)) * 255);
%     mm = mm(1:18,:);
%     x=[1:18]; xi = [2:36] / 2;
%     mm = interp1(x,double(mm), xi);
%     maskMap = mm;
%     maskMap(1:2:32,:) = mm(1:16,:);
%     maskMap(2:2:32,:) = mm(17:32,:);
%     markMap = maskMap / 255;
%     maskMap = uint8(maskMap);
    
    %  compose the mask + data image using alpha blending
    %maskMap = uint8(colormap(colorcube(40)) * 255);
    %markMap = colormap(colorcube(40));
    for n=1:nFilterIDs
        %if n==29; continue; end
        mf = bitget(mask, maskIDs(n));
        aidx = (mf == 1);
        alpha=40;
        if any(any(mf))
            %  50/50 fast alpha method
%             temp = data(:,:,1);
%             temp(mf == 1) = bitshift(maskMap(maskIDs(n),1), -1) + ...
%                 bitshift(temp(mf == 1), -1);
%             data(:,:,1) = temp;
%             temp = data(:,:,2);
%             temp(mf == 1) = bitshift(maskMap(maskIDs(n),2), -1) + ...
%                 bitshift(temp(mf == 1), -1);
%             data(:,:,2) = temp;
%             temp = data(:,:,3);
%             temp(mf == 1) = bitshift(maskMap(maskIDs(n),3), -1) + ...
%                 bitshift(temp(mf == 1), -1);
%             data(:,:,3) = temp;

            %  variable alpha method (slower)
            temp = single(data(:,:,1));
%             temp(aidx) = temp(aidx) + (((single(maskMap(maskIDs(n),1)) - ...
%                 temp(aidx)) / 255) * alpha);
            temp(aidx) = temp(aidx) + (((single(maskMap(n,1)) - ...
                temp(aidx)) / 255) * alpha);
            data(:,:,1) = uint8(temp);
            temp = single(data(:,:,2));
%             temp(aidx) = temp(aidx) + (((single(maskMap(maskIDs(n),2)) - ...
%                 temp(aidx)) / 255) * alpha);
            temp(aidx) = temp(aidx) + (((single(maskMap(n,2)) - ...
                temp(aidx)) / 255) * alpha);
            data(:,:,2) = uint8(temp);
            temp = single(data(:,:,3));
%             temp(aidx) = temp(aidx) + (((single(maskMap(maskIDs(n),3)) - ...
%                 temp(aidx)) / 255) * alpha);
            temp(aidx) = temp(aidx) + (((single(maskMap(n,3)) - ...
                temp(aidx)) / 255) * alpha);
            data(:,:,3) = uint8(temp);
            
            
            %  create an element for the mask legend
            hLine = line('XData',1, 'YData' ,1, 'Marker', 's', 'MarkerFaceColor', ...
                markMap(n,:), 'MarkerSize', 12, 'Visible', 'off', 'LineStyle', ...
                'none', 'Parent', hiddenAxes);
            lHandles = [lHandles hLine];
            lText = {lText{:} fNames{maskIDs(n)}};
        end
    end
    temp = [];
    
    %  create the legend
    set(figHandle, 'CurrentAxes', parent);
    h.legend = legend(lHandles,lText, 'Location', 'NorthEastOutside', ...
        'HandleVisibility', 'off');%, 'Parent', parent);
    set(hiddenAxes, 'HandleVisibility', 'off');
end


%  free mask arrays
clear('mf', 'aidx', 'mask');

try
    %  add the echogram image to the figure
    set(figHandle, 'Colormap', dataRGB);
    if (size(data,3) == 1)
        %  plot echogram as 8-bit indexed image
        h.image = image('Xdata', xData, 'Ydata', yData,'CData', data, ...
            'Parent', parent);
    else
        %  plot echogram as 32-bit true color image
        if (isinteger(data)); data = single(data) / 255; end
        h.image = image('Xdata', xData, 'Ydata', yData,'CData', data, ...
            'Parent', parent);
    end
    
catch
    
    %  failed to create image - usually this is because our image is too
    %  big so we'll resize it and try again.  We won't have enough memory
    %  to interp so we'll just decimate.  crude fix for now...
    
    xData(1:3:end) = [];
    data(:,1:3:end,:) = [];
    h.image = image('Xdata', xData, 'Ydata', yData,'CData', data, ...
            'Parent', parent);
end


%  add a colorbar to the figure - currently unsupported in anglogram mode
if (showCB) && (mode == 0)
    %  set number of intervals (assume 1st interval is outside threshold range)
    nColors = length(dataRGB) - 1;
    lSpacing = 1;
    
    %  limit to 20 intervals (21 labels) max
    if (nColors > 20)
        lSpacing = (nColors / 20);
        nColors = 19;
    end
    
    %  create label strings
    cbValues = num2str(([-1:nColors+1] * ((threshold(2) - threshold(1)) / ...
        nColors) + threshold(1))', '%5.1f');
    
    %  create vector of label locations
    cbLocs = ([0:nColors+1] * lSpacing) + 0.5;
    
    %  create the colorbar
    h.colorbar = colorbar('YTickLabel', num2str(cbValues, '%4.0f'), ...
        'YTick', cbLocs);%, 'Parent', figHandle);
end

end


function rgb = ek500(g)
%  ek500 - return a 13x3 array of RGB values representing the Simrad EK500 color table

    rgb = [[255 255 255];
           [159 159 159];
           [095 095 095];
           [000 000 255];
           [000 000 127];
           [000 191 000];
           [000 127 000];
           [255 255 000];
           [255 127 000];
           [255 000 191];
           [255 000 000];
           [166 083 060];
           [120 060 040]];

    %  adjust the "gamma" (only works for positive (white shift) changes
    if (g ~= 0); rgb = rgb + (255 - rgb) * g; end
       
    rgb = rgb / 255.;
   
end