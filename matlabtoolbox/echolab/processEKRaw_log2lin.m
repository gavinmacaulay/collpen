function pings = processEKRaw_log2lin(pings, varargin)
%processEKRaw_log2lin  convert from Sv to sv
%   pings = processEKRaw_log2lin(pings) returns an echolab "pings" structure 
%       where Sv has been converted to sv.  The Sv data is discarded after
%       conversion.
%
%   REQUIRED INPUT:
%           pings:  Set this parameter to a scalar instance of the pings structure 
%                   from the echolab data structure.  Alternatively you can set
%                   the "isMatrix" parameter to true to convert a matrix of Sv
%                   data instead of Sv data contained in the pings structure.
%
%   OPTIONAL PARAMETERS:
%
%        isMatrix:  Set this parameter to true to process the input parameter as
%                   a simple matrix of Sv data.
%
%                   Default: false
%
%   OUTPUT:
%       A modified pings structure where the Sv field has been converted to the
%       sv field.  Or if the isMatrix parameter is true, a converted matrix.
%       
%   REQUIRES:
%       None.
%
%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  define defaults
isMat = false;                  %  by default, assume pings data struct passed

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'ismatrix'
            isMat = varargin{n + 1} > 0;
        otherwise
            warning('processEKRaw:ParameterError', ['Unknown property name: ' ...
                varargin{n}]);
    end
end

if (isMat)
    %  simple matrix passed - convert
    pings = 10.^(pings / 10);
else
    %  echolab "pings" structure passed - convert
    if (~isfield(pings,'Sv'))
        warning('processEKRaw:log2lin', 'Pings structure does not contain Sv field');
        return
    end

    pings.sv = 10.^(pings.Sv / 10);
    pings = rmfield(pings, 'Sv');
end

