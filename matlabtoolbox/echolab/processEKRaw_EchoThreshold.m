function [data, mask] = processEKRaw_EchoThreshold(data, mask, min, max, varargin)

%  see if I can can the out structure and output [data mask].  Seems to work
%  in some cases, but I had issues with type in this function where mask was
%  re-typed to double (?) from uint32.

global EKMASKBITS

%  set default values
setThresh = 0;          %  Default to setting max threshold to "exclude"

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'setmaxthreshto'
            setThresh = varargin{n + 1};
        otherwise
            warning(['Unknown property name: ' varargin{n}]);
    end
end

%  create the output structure
%out = struct('data', data, 'mask', mask);

%  mask samples that fall below minimum threshold
didx = data < min;
%out.mask(didx) = bitset(out.mask(didx), EKMASKBITS.thresholdLow, 0);
mask(didx) = bitset(mask(didx), EKMASKBITS.thresholdLow, 0);
%out.data(didx) = 0;


%  mask samples that fall above maximum threshold
didx = data > max;
%out.mask(didx) = bitset(out.mask(didx), EKMASKBITS.thresholdHigh, 0);
mask(didx) = bitset(mask(didx), EKMASKBITS.thresholdHigh, 0);

if (setThresh == 0)
    %  treat these samples as bad data
    %out.mask(didx) = bitset(out.mask(didx), EKMASKBITS.valid, 0);
    mask(didx) = bitset(mask(didx), EKMASKBITS.valid, 0);
else
    %  treat as good data but set to specified max value
    %out.data(didx) = setThresh;
    data(didx) = setThresh;
end