function pings = processEKRaw_lin2log(pings, varargin)
%processEKRaw_lin2log  convert from sv to Sv
%   pings = processEKRaw_lin2log(pings) returns an echolab "pings" structure 
%       where sv has been converted to Sv.  The sv data is discarded after
%       conversion.
%
%   REQUIRED INPUT:
%           pings:  Set this parameter to a scalar instance of the pings structure 
%                   from the echolab data structure.  Alternatively you can set
%                   the "isMatrix" parameter to true to convert a matrix of sv
%                   data instead of sv data contained in the pings structure.
%
%   OPTIONAL PARAMETERS:
%
%        isMatrix:  Set this parameter to true to process the input parameter as
%                   a simple matrix of sv data.
%
%                   Default: false
%
%   OUTPUT:
%       A modified pings structure where the sv field has been converted to the
%       Sv field.  Or if the isMatrix parameter is true, a converted matrix.
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
    pings = 10 * log10(pings);
else
    if (~isfield(pings,'sv'))
        warning('processEKRaw:sv2Sv', 'Pings structure does not contain sv field');
        return
    end

    pings.Sv = 10 * log10(pings.sv);
    pings = rmfield(pings, 'sv');
end

