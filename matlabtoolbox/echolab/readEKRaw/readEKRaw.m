function [header, data, varargout] = readEKRaw(filename, varargin)
%readEKRaw  Read EK/ES60 ME/MS70 raw data files
%   [header, data] = readEKRaw(filename, varargin) returns two arrays
%       containing the raw file header data and a structure containing the
%       raw data.
%
%   REQUIRED INPUT:
%
%          filename:    A string containing the path to the file to read.
%
%
%   OPTIONAL PARAMETERS:

%   AllowModeChange:    Set this parameter to True to properly read data files
%                       where the beam mode changes within the file. By default
%                       readEKRaw assumes that the beam mode will not change
%                       which reduces RAM utilization in cases where only
%                       power (mode 1) or only angle data (mode 2) are collected.
%                       Typically you should not need to change this parameter
%                       unless readEKRaw issues an error telling you to set
%                       it.
%
%                       A common case where you do need to set this is when data
%                       is collected from mixed single and split-beam systems.
%                       
%                           Default: False
%
%            Angles:    Set this parameter to True to return alongship and
%                       athwartship electrical angle data (splitbeam only).
%                       Set it to False to ignore the angle data in the raw file. 
%                           Default: True
%
%       Annotations:    Set this parameter to True to return the 'TAG'
%                       annotation datagrams.
%                           Default: False
%
%           Channel:    NOT IMPLEMENTED (YET) - Specify channel to load
%
%          Continue:    Set this parameter to True to start reading the file
%                       from the point specified in the ReaderState structure
%                       (see ReaderState below).  While a bit crude, this allows
%                       one to read raw files in chunks in cases where it is
%                       unreasonable to read the entire file into memory at
%                       once.  Note that setting this parameter without setting
%                       the ReaderState parameter has no effect.
%                           Default: False
%                       
%       Frequencies:    A scalar or vector of frequency values (in Hz) to
%                       return.  Set this to limit reading data to specific
%                       frequencies.
%                           Default: -1  (return all frequencies)
%
%           GeoConn:    Set this parameter to a Nx2 array defining the
%                       vertex connectivity of the GeoRegion polygon array.
%                       This parameter is optional and only required if
%                       GeoRegion contains multiple polygons definitions.
%                           Default: -1 (no connectivity array provided)
%
%         GeoRegion:    Set this parameter to a Nx2 array defining the vertices
%                       of the geographic region for which data is to be returned.
%                       The array defines a polygon where data collected in the
%                       polygon is read and data outside the polygon is
%                       discarded.  Set this parameter to -1 to return all data
%                       regardless of geographic location.
%
%                       When this parameter is set, data.gps gains an additional
%                       field "seg" which is an int16 vector of length N-fixes
%                       identifying continuous segments as fixes which share a
%                       segment ID.  Positive ID's are segments that are in the
%                       region and negative ID's are out.  Segment ID's start at
%                       1 and increment or decrement by 1 for each segment.
%                       Segment ID's of 0 do not belong to any segment as they
%                       are not bracketed by GPS fixes and thus cannot be
%                       assigned to a region.
%
%                       The array is in the form [lat1, lon1; lat2, lon2; ...]
%                       and unless the GeoConn parameter is set, it is assumed
%                       that the vertices are passed in consecutive order (1st
%                       is joined to the 2nd and so on)
%                           Default: -1  (do not limit by geographic region)
%
%               GPS:    Set this parameter to 1 to return GPS data as type
%                       single.  Set this parameter to 2 to return GPS data as
%                       type double.  Set it to 0 to not return GPS data.
%
%                       When returning GPS data, an additional field "seg"
%                       is returned in the ping structure containing the GPS
%                       track segment that that each ping belongs to.  If the
%                       GeoRegion and MaxSegGap parameters are set to their
%                       defaults, there will be 1 and only 1 segment (with a
%                       value of 1). Segment values of 0 belong to no track and
%                       occur when a ping is not bracketed by GPS fixes.
%
%                       Processing GPS data is costly, set this only if you
%                       require GPS data.
%                           Default: 2
%
%           GPSOnly:    Set this parameter to True to return *only* GPS data.
%                           Default: False
%
%         GPSSource:    Set this parameter to a string defining the GPS NMEA
%                       datagram to use as the source of GPS data.  You must
%                       specify both the Talker ID (i.e. IN or GP) and the
%                       Sentence ID.  Supported sentence IDs are 'GGA' and
%                       'GLL'.  Set this parameter to a cell array of strings
%                       to read multiple types (usually this will simply return
%                       duplicate data).
%                           Default: 'GPGGA'
%
%             Heave:    Set this parameter to True to return heave data.
%                           Default: False
%
%       MaxBadBytes:    Set this parameter to a scalar defining the number
%                       of bytes readEKRaw will search past a bad datagram
%                       for the next good datagram.  readEKRaw will scan
%                       the .raw file byte by byte starting at the last
%                       good datagram looking for the next valid datagram.
%                       This is *very* time consuming and this parameter
%                       allows you to set a limit on this search.  Set this
%                       value to Inf to search to the end of the file.  Set
%                       this to 0 to disable any search and simply exit
%                       when a bad datagram is encountered.
%                           Default: 5000
%
%    MaxSampleRange:    Set this parameter to a scalar defining the upper
%                       limit on the number of samples to store.  If the
%                       number of samples in a ping exceeds this value, all
%                       samples beyond the maximum will be dropped.  This
%                       parameter is different than setting the SampleRange
%                       in that it allows for dynamic sizing of the output
%                       arrays and only sets the upper limit for the output
%                       array size.  Useful for data files with errant
%                       pings containing abnormally high number of samples
%                       (seen occasionally in ES60 data.)
%                           Default: 30,000 (no artificial max)
%
%         MaxSegGap:    Set this parameter to a scalar defining the maximum
%                       distance (in m) between successive GPS fixes in a
%                       single segment.  When the distance between 2 GPS
%                       fixes exceeds this value, the segment is broken and
%                       the latter fix is assigned a new segment value. Set
%                       this value to -1 to disable gap detection.
%                           Default: -1
%
%         PingRange:    A 2 element vector in the form [start end] or a 3 element
%                       vector in the form [start stride end] defining the
%                       ping range to read from the file.  Files start at ping
%                       number 1.  To read to the end of the file, set end to Inf.
%                       You can set PingRange, or TimeRange.  Not both.
%                           Default: [1 1 Inf] - read entire file
%
%             Pitch:    Set this parameter to True to return picth data.
%                           Default: False
%
%             Power:    Set this parameter to True to return sample power data.
%                       Set it to false to ignore the power data in the raw
%                       file.
%                           Default: True
%
%  ProgressCallback:    Set this parameter to a function handle that will be
%                       called with a single parameter denoting the progress of
%                       the reader.  The value will range from 0 (start of file)
%                       to 1 (end of file).
%                           Default: Undefined
%
%ProgressGranularity:   Set this parameter to a scalar in the range from 0.1 to
%                       100 specifying the minimum change in percent in the
%                       progress of reading the raw file required to trigger a
%                       call to the function defined by ProgressCallback.  This
%                       parameter allows one to minimize the overhead of the
%                       progress callback function while still providing
%                       feedback.
%                           Default: 2
%
%           RawNMEA:    Set this parameter to True to return unprocessed
%                       NMEA data.  Setting this parameter returns ALL NMEA
%                       data.  Use the UserNMEA parameter to return specific
%                       talker and sentence ID datagrams.  Setting both the
%                       RawNMEA and UserNMEA fields works, but results in a
%                       slighly awkward NMEA structure
%                           Default: False
%
%       ReaderState:    Set this parameter to an instance of the "rstat"
%                       structure (defined below) to enable continuity of
%                       certain parameters between calls to readEKRaw.  This
%                       allows data such as ping number and segment numbers to
%                       remain meaningful when multiple *continuous* files are
%                       read.  This parameter is also is required when reading
%                       files in chunks using the 'Continue' parameter.
%                           Default: []
%
%RequireGPSChecksum:    Set this parameter to true to require that the NMEA GPS
%                       sentences have a checksum. If set to true and a GPS NMEA
%                       sentence lacks a checksum it will be ignored. Set to false 
%                       to process GPS sentences with or without a checksum. By
%                       default readEKRaw only requires a checksum if there is a
%                       checksum present on the first NMEA GPS string processed.
%                           Default: []
%
%              Roll:    Set this parameter to True to return roll data.
%                           Default: False
%
%       SampleRange:    A 2 element vector in the form [start,end] defining the
%                       samples to read from a file.  If this parameter is
%                       set, the sample range is not dynamically sized.
%                           Default: [1 Inf] - read all samples
%
%            Skinny:    Set this parameter to a non-zero value indicating the
%                       ping which you want to read the ping-by-ping transceiver
%                       parameters.  This forces the reader to store these
%                       parameters once and is useful in limiting memory
%                       requriements for files where these parameters do not
%                       change.  The following parameters are affected:
%
%                                    transducerdepth
%                                    frequency
%                                    transmitpower
%                                    pulselength
%                                    bandwidth
%                                    sampleinterval
%                                    soundvelocity
%                                    absorptioncoefficient
%                                    offset
%
%                           Default: 0 - Store parameters for every ping
%
%       Temperature:    Set this parameter to True to return temperature data.
%                           Default: False
%
%        TimeOffset:    Set this parameter to a scalar value denoting the time
%                       offset, in hours, to be applied to the data to
%                       compensate for a misconfigured data collection PC.
%                           Default: 0
%
%       The timeOffset parameter is helpful in syncing pings with external events.
%       While most protocols call for collecting data with the PC's clock set to
%       GMT, a common mistake is to set the clock to GMT without adjusting the
%       time zone to GMT as well.  The Simrad EK/ES60 software automatically
%       applies the time zone offset to the PC's local clock to convert time to
%       GMT so this misconfiguration results in ping times that are incorrect.
%       The timeOffset parameter will allow you to adjust for this.
%
%         TimeRange:    A 2 element vector in the form [start end] defining the
%                       time range to read from the file.  Time values are in
%                       MATLAB serial time.  To read to the end of the file, set
%                       end to Inf.  You can set PingRange, or TimeRange. Not both.
%                           Default: [0 Inf] - read entire file
%
%             Trawl:    Set this parameter to True to return trawl data.  Traw
%                       data consists of trawl upper depth and trawl opening
%                       data.
%                           Default: False
%
%          UserNMEA:    Set this parameter to a cell array of user defined
%                       NMEA IDs (Talker and Sentence, i.e. 'TTSSS') to be extracted
%                       from the raw file.  The data will be inserted into the NMEA
%                       output structure unmodified.  User defined NMEA strings
%                       offer a convienient method to store complimentary data 
%                       streams in a raw file.
%                           Default: {}
%
%         VesselLog:    Set this parameter to 1 to return VLW data as type single.
%                       Set it to 2 to return VLW data as type double.  Set it to
%                       0 to not return VLW data.
%                           Default: 0
%
%         VLWSource:    Set this parameter to a string defining the Talker ID
%                       for the VLW NMEA datagram to use as the source of VLW
%                       data.  In most cases you should leave this set to
%                       the default Simrad 'SD' talker ID.
%                           Default: 'SD'
%
%       VesselSpeed:    Set this parameter to 1 to return vessel speed in knots 
%                       as reported in the NMEA VTG datagram as type single. Set it 
%                       to 2 to return this data as type double.  Set it to 0 to
%                       not return vessel speed data.
%                           Default: 0
%
%         VTGSource:    Set this parameter to a string defining the Talker ID
%                       for the VTG NMEA datagram to use as the source of VTG
%                       data.  VTG datagrams from GPS receivers will have a
%                       talker ID of 'GP'.  POS/MV systems have a talker ID
%                       of 'IN'.
%                           Default: 'GP'
%
%   OUTPUT: Output is two structures containing the raw data.  All times are in
%           MATLAB serial time.
%
%           header: A structure containing file header information in the form:
%
%                                         surveyname: [1x128 char]
%                                       transectname: [1x128 char]
%                                        soundername: [1x128 char]
%                                              spare: [1x128 char]
%                                   transceivercount: 0
%
%
%             data: Assuming M transceivers, N pings and Q samples, data is a
%                   structure in the form:
%
%                     config: 1xM structure array containing the transceiver
%                             specific configuration data in the form:
%
%                                          channelid: [1x128 char]
%                                           beamtype: 0
%                                          frequency: 0
%                                               gain: 0
%                                equivalentbeamangle: 0
%                                 beamwidthalongship: 0
%                               beamwidthathwartship: 0
%                          anglesensitivityalongship: 0
%                        anglesensitivityathwartship: 0
%                              anglesoffsetalongship: 0
%                             angleoffsetathwartship: 0
%                                               posx: 0
%                                               posy: 0
%                                               posz: 0
%                                               dirx: 0
%                                               diry: 0
%                                               dirz: 0
%                                   pulselengthtable: [5x1 double]
%                                             spare2: ''
%                                          gaintable: [5x1 double]
%                                             spare3: ''
%                                  sacorrectiontable: [5x1 double]
%                                             spare4: ''
%
%                      pings: 1xM structure array containing the ping specific
%                             data.  Some fields are optional (determined by
%                             parameters passed to the reader).  The structure
%                             is in the form:
%
%                                             number: [1xN uint32]
%                                               time: [1xN double]
%                                    transducerdepth: [1xN single] or [1x1 single]
%                                          frequency: [1xN single] or [1x1 single]
%                                      transmitpower: [1xN single] or [1x1 single]
%                                        pulselength: [1xN single] or [1x1 single]
%                                          bandwidth: [1xN single] or [1x1 single]
%                                     sampleinterval: [1xN single] or [1x1 single]
%                                      soundvelocity: [1xN single] or [1x1 single]
%                              absorptioncoefficient: [1xN single] or [1x1 single]
%                                              heave: [1xN single] optional
%                                              pitch: [1xN single] optional
%                                               roll: [1xN single] optional
%                                        temperature: [1xN single] optional
%                                  trawlopeningvalid: [1xN int16]  optional
%                               trawlupperdepthvalid: [1xN int16]  optional
%                                    trawlupperdepth: [1xN single] optional
%                                       trawlopening: [1xN single] optional
%                                             offset: [1xN int32] or [1x1 single]
%                                              count: [1xN int32]
%                                              power: [QxN single] optional
%                                        alongship_e: [QxN int8] optional
%                                      athwartship_e: [QxN int8] optional
%                                        samplerange: [StartSample nSamples]
%                                                seg: [1xN int16]  optional
%
%                        gps: 1x1 structure containing GPS data.  Assuming W gps
%                             fixes, the structure is in the form:
%
%                                               time: [Wx1 double]
%                                                lat: [Wx1 double]
%                                                lon: [Wx1 double]
%                                                seg: [Wx1 int16]  optional
%
%                       NMEA: 1x1 structure containing raw NMEA data.
%                             Assuming P NMEA datagrams the structure is in
%                             the form:
%
%                                               time: [Px1 double]
%                                             string: {Px1 char}
%
%                             If the UserNMEA parameter is defined additional
%                             fields will be present in the NMEA structure named
%                             after the talker/sentence IDs contained in
%                             UserNMEA.
%
%                       vlog: 1x1 structure containing vessel log data. Assuming
%                             R vessel log records the structure is in the form:
%
%                                               time: [Rx1 double]
%                                               vlog: [Rx1 single]
%                                                seg: [Rx1 int16]  optional
%
%                     vspeed: 1x1 structure containing vessel speed data. Assuming
%                             S vessel speed records the structure is in the form:
%
%                                               time: [Sx1 double]
%                                             vspeed: [Sx1 single]
%                                                seg: [Sx1 int16]  optional
%
%                annotations: 1x1 structure containing annotation (TAG0) data.
%                             Assuming  T annotaions the structure is in the
%                             form:
%
%                                               time: [Tx1 double]
%                                               text: {Tx1 char}
%                       conf: 1x1 structure containing ME70 configuration 
%                             (CON1) data. The structure is in the form:
%
%                                               time: [Tx1 double]
%                                               text: {Tx1 char}
%
%                             The CON1 XML string is non-conformant in that the
%                             values for each node are stored within the opening
%                             tag as "value" instead of between the opening and
%                             closing tag.  As a result, most XML parsers cannot
%                             parse the string correctly.  Until a custom parser
%                             is written, the XML text will be returned.
%
%
%            rstat: 1x1 structure containing parameters used by the
%                   reader when reading multiple continuous files.
%                   The structure is in the form:
%
%                                    pingnum: [1xN uint32]  last ping number
%                                   segState: [2x1 uint16]  segment ending values
%                                   inRegion: [1x1 bool]    last ping was in/out of ROI
%                                        lat: [1x1 double]  last lat fix
%                                        lon: [1x1 double]  last lon fix
%                                     dgTime: [1x1 double]  time of last GPS fix
%                                       fpos: [1x1 int32]   ending file pointer location
%
%               NOTE: The GPS fix contained in the rstat structure will be
%                     used as the initial GPS fix for the file being read if
%                     it within MAXRSTATGPSM meters of the first fix read
%                     by readEKRaw. When used as recommended on CONTINUOUS
%                     files, this should never be an issue, but if
%                     accidently used on two non-contiguous files this provides
%                     a sanity check and the lat/lon from rstat will not be
%                     used. MAXRSTATGPSM is not exposed as a keyword and as
%                     of this writing is set as a constant at the top of the
%                     readEKRaw code at 500m.
%
%   REQUIRES:
%               vdist.m  (older non-vectorized version is faster in this application)
%               inpoly.m
%
%               These functions are included in the readEKRaw package.
%

%   Rick Towler
%   National Oceanic and Atmospheric Administration
%   Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%
%   This code is based on code by Lars Nonboe Andersen, Simrad; Rueben Patel, IMR,
%   and much input from Nils Olav "give me one more feature" Handegard, IMR.

%-

%  define constants
HEADER_LEN = 12;                %  Bytes in datagram header
CHUNK_SIZE = 2500;              %  size in array elements of allocation "chunks"
MAXRSTATGPSM = 500;             %  max distance (m) between rstat GPS fix and first read GPS fix

%  define default parameters
returnFreqs = -1;               %  Return all frequencies by default
timeOffset = 0;                 %  Assume logging PC time and timezone set correctly
rData.angle = true;             %  Return alon and athw electrical angles by default
rData.annotations = false;      %  Do not return annotations by default
rData.continue = false;         %  default is non-continuation mode
rData.gps = true;               %  Return GPS data (even if none available)
rData.gpsOnly = false;          %  Return all data, not just GPS
rData.gpsType = 'double';       %  Return GPS as double
rData.gpsSource = 'GPGGA';      %  Use GGA datagrams as GPS data source
rData.heave = false;            %  Do not return heave by default
rData.pitch = false;            %  Do not return pitch by default
rData.power = true;             %  Return power by default
rData.rawNMEA = false;          %  Do not return raw NMEA data
rData.roll = false;             %  Do not return roll by default
rData.skinny = uint32(0);       %  Return all ping-by-ping param data by default
rData.trawl = false;            %  Do not return trawl data by default
rData.temp = false;             %  Do not return temperature by default
rData.uNMEA = false;            %  Do not return user defined NMEA data
rData.vlog = false;             %  Do not return vessel log data
rData.vlogType = 'single';      %  Return vessel log as single
rData.vlwSource = 'SD';         %  Use the SD talker ID for VLW datagrams
rData.vSpeed = false;           %  Do not return vessel speed data
rData.vSpeedType = 'single';    %  Return vessel speed as single
rData.vtgSource = 'GP';         %  Use the GP talker ID for VTG datagrams
pingRange = [1 1 Inf];          %  Do not limit by ping and read all pings by default
timeRange = [0 Inf];            %  Do not limit by time by default
sampleRange = uint16([1 Inf]);  %  Do not limit by sample by default
maxSampleRange = uint16(30000); %  Effectively no maximum limit
geoRegion = -1;                 %  Geographic region is undefined by default
geoConn = -1;                   %  No explicit polygon connectivity provided
rData.doGeo = false;            %  Don't limit data by geographic region (ROI)
isInRegion = true;              %  All points are in the ROI by default
rparms = -1;                    %  By default the reader parameters are unset.
maxSegGap = -1;                 %  By default, do not test for spatial gaps in data
progressCallback = [];          %  No progress callback function defined
progressGranularity = 2;        %  Minimum percent change in progress before callback is called
userNMEA = {};                  %  By default the user defined NMEA array is undefined
maxBadBytes = 5000;             %  Keep reading 5000 bytes past a bad datagram for a good one
allowBeamModeChange = false;    %  By default assume beam mode will not change.
rGPSChecksums = -1;             %  Only require checksums if the first NMEA GPS string has them
beamMode = -1;                  %  Initial beam mode is unset.


rChecksums = [false,false,false,false]; 

%  process property name/value pairs
for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case {'frequency' 'frequencies'}
            %  limit data returned to these frequencies (in Hz)
            returnFreqs = sort(varargin{n + 1});
        case 'timeoffset'
            %  set logging PC timezone offset
            timeOffset = varargin{n + 1};
        case 'skinny'
            rData.skinny = uint32(varargin{n + 1});
        case 'geoconn'
            %  set geographic region polygon connectivity
            grSize = size(varargin{n + 1});
            if (grSize(1) > 2) && (grSize(2) ==2)
                geoConn = varargin{n + 1};
            else
                if (varargin{n + 1} == -1)
                    geoConn = varargin{n + 1};
                else
                    warning('readEKRaw:ParameterError', ['GeoConn - Incorrect ' ...
                        'array size.  Must be a Nx2 array of vertex ids pairs where N > 2.']);
                end
            end
        case 'georegion'
            %  set geographic region
            grSize = size(varargin{n + 1});
            if (grSize(1) > 2) && (grSize(2) ==2)
                geoRegion = varargin{n + 1};
                rData.doGeo = true;
                rData.gps = true;
            else
                if (varargin{n + 1} == -1)
                    geoRegion = varargin{n + 1};
                    rData.doGeo = false;
                else
                    warning('readEKRaw:ParameterError', ['GeoRegion - Incorrect ' ...
                        'array size.  Must be a Nx2 array of Lat,Lon pairs where N > 2.']);
                end
            end
        case 'readerstate'
            rparms = varargin{n + 1};
        case 'requiregpschecksum'
            %  explicitly set the GPS checksum requirement
            rGPSChecksums = varargin{n + 1} > 0;
            if rGPSChecksums
                rChecksums = [true, true, rChecksums(3), rChecksums(4)];
            else
                rChecksums = [false, false, rChecksums(3), rChecksums(4)];
            end
        case 'pingrange'
            %  set starting and ending pings to load
            switch length(varargin{n + 1})
                case 2
                    pingRange = ones(1,3);
                    pingRange(1) = varargin{n + 1}(1);
                    pingRange(3) = varargin{n + 1}(2);
                case 3
                    pingRange = varargin{n + 1};
                otherwise
                    warning('readEKRaw:ParameterError', ['PingRange - Incorrect ' ...
                        'number of arguments. PingRange must be a 2 or 3 ' ...
                        'element vector [pingStart pingEnd] or [pingStart ' ...
                        'pingStride pingEnd]']);
            end
            if (pingRange(3) < pingRange(1))
                error('PingRange - pingStart is greater than pingEnd');
            end
            % adjust chunk size if nPings is small
            nPings = pingRange(3) - pingRange(1) + 1;
            if (nPings < CHUNK_SIZE); CHUNK_SIZE = nPings; end
        case 'timerange'
            %  set starting and ending times to load
            if (length(varargin{n + 1}) == 2)
                timeRange = varargin{n + 1};
                if (timeRange(2) < 0); timeRange(2) = Inf; end
                if (timeRange(2) < timeRange(1))
                    error('TimeRange - timeStart is greater than timeEnd');
                end
            else
                warning('readEKRaw:ParameterError', ['TimeRange - Incorrect ' ...
                    'number of arguments. TimeRange must be a 2 element vector ' ...
                    '[timeStart timeEnd]']);
            end
        case 'samplerange'
            if (length(varargin{n + 1}) == 2)
                sampleRange = uint16(varargin{n + 1});
                if (sampleRange(2) < 0); sampleRange(2) = Inf; end
                if (sampleRange(2) < sampleRange(1))
                    error('SampleRange - sampleStart is greater than sampleEnd');
                end
            else
                warning('readEKRaw:ParameterError', ['SampleRange - Incorrect ' ...
                    'number of arguments. SampleRange must be a 2 element ' ...
                    'vector [sampleStart sampleEnd]']);
            end
        case 'maxsamplerange'
            maxSampleRange = uint16(varargin{n + 1});
            if (maxSampleRange < 1); maxSampleRange = 1; end
            if (maxSampleRange > 30000); maxSampleRange = 30000; end
        case 'heave'
            rData.heave = (0 < varargin{n + 1});
        case 'continue'
            rData.continue = (0 < varargin{n + 1});
        case 'roll'
            rData.roll = (0 < varargin{n + 1});
        case 'pitch'
            rData.pitch = (0 < varargin{n + 1});
        case 'trawl'
            rData.trawl = (0 < varargin{n + 1});
        case {'temperature' 'temp'}
            rData.temp = (0 < varargin{n + 1});
        case 'power'
            rData.power = (0 < varargin{n + 1});
        case 'angles'
            rData.angle = (0 < varargin{n + 1});
        case 'annotations'
            rData.annotations = (0 < varargin{n + 1});
        case 'rawnmea'
            rData.rawNMEA = (0 < varargin{n + 1});
        case 'gps'
            rData.gps = (0 < varargin{n + 1});
            if (varargin{n + 1} > 1); rData.gpsType = 'double'; else ...
                    rData.gpsType = 'single'; end
        case 'gpsonly'
            rData.gpsOnly = (0 < varargin{n + 1});
        case 'gpssource'
            rData.gpsSource = varargin{n + 1};
        case 'maxseggap'
            maxSegGap = varargin{n + 1};
        case 'maxbadbytes'
            maxBadBytes = varargin{n + 1};
        case 'usernmea'
            if iscell(varargin{n + 1})
                userNMEA = varargin{n + 1};
                rData.uNMEA = true;
            else
                warning('readEKRaw:ParameterError', ['UserNMEA argument must be' ...
                ' a cell array']);
            end
        case 'vessellog'
            rData.vlog = (0 < varargin{n + 1});
            if (varargin{n + 1} > 1); rData.vlogType = 'double'; else ...
                    rData.vlogType = 'single'; end
        case 'vtgsource'
            rData.vtgSource = varargin{n + 1};
        case 'vlwsource'
            rData.vlwSource = varargin{n + 1};
        case 'vesselspeed'
            rData.vSpeed = (0 < varargin{n + 1});
            if (varargin{n + 1} > 1); rData.vSpeedType = 'double'; else ...
                    rData.vSpeedType = 'single'; end
        case 'progresscallback'
            if (isa(varargin{n + 1}, 'function_handle')); ...
                progressCallback = varargin{n + 1}; end
        case 'progressgranularity'
                progressGranularity = varargin{n + 1};
        case 'allowmodechange'
            allowBeamModeChange = (0 < varargin{n + 1});
        otherwise
            warning('readEKRaw:ParameterError', ['Unknown property name: ' ...
                varargin{n}]);
    end
end


%  open the raw file
[pathstr, name, ext] = fileparts(filename);
fid = fopen(filename, 'r');
if (fid == -1)
    header = -1; data = -1; varargout = {-1};
    warning('readEKRaw:IOError', 'Could not open raw file: %s%s',name,ext);
    return;
end

%  read configuration datagram 'CON0'
[config, frequencies] = readEKRaw_ReadHeader(fid);


if (~rData.gpsOnly)
    
    %  define channel ID array
    CIDs = 1:config.header.transceivercount;
    
    %  Check if we're limiting data by frequency
    if (returnFreqs(1) > 0)
        %  remove transceivers we're not interested in - set operators
        %  don't work when we have multiple channels at the same frequency
        %  so we do it the hard way...
        rIdx = frequencies ~= returnFreqs(1);
        for n=2:length(returnFreqs)
            rIdx = rIdx & (frequencies ~= returnFreqs(n));
        end
        config.transceiver(rIdx) = [];
        CIDs(rIdx) = [];
        %  update header data to reflect change
        config.header.transceivercount = config.header.transceivercount - ...
            sum(rIdx);
        header = config.header;
    else
        %  no specific freqs set - return all frequencies in the file
        returnFreqs = frequencies;
        header = config.header;
    end

    %  get initial sample counts for each freq - first try the 4th ping.
    %  certain files of mine had unusual sample numbers for the first
    %  ping so looking a bit into the file avoids this.
    nSamples = readEKRaw_GetSampleCount(fid, CIDs, sampleRange, maxSampleRange, 4);

    %  check for errant sampleRange parameters or very short files
    badRanges = find(nSamples == 0);
    if ~isempty(badRanges)
        %  try to get sample range from the first ping (very short file)
        nSFP = readEKRaw_GetSampleCount(fid, CIDs(badRanges), sampleRange, ...
            maxSampleRange, 1);
        nSamples(badRanges) = nSFP;
        badRanges = find(nSamples == 0);
        if ~isempty(badRanges)
            %  still unable to get sample count, either the file contains no data
            %  or the sample count is out of range.  Issue warning and remove channels
            warning('readEKRaw:IOError', ['sampleRange is out of range. ' ...
                'Transceiver(s) dropped.']);
            config.transceiver(badRanges) = [];
            CIDs(badRanges) = [];
            %  update header data to reflect change
            config.header.transceivercount = config.header.transceivercount - ...
                length(badRanges);
        end
    end

    %  return if we're left with no xcvrs
    if (config.header.transceivercount <= 0)
        warning('readEKRaw:IOError', ['The specified frequencies are not ' ...
            'in the file.']);
        fclose(fid);
        header = -1; data = -1; varargout = {-1};
        return;
    end
    
    %  allocate sampledata structure
    sampledata = readEKRaw_AllocateSampledata(max(nSamples));
    transceivercount = config.header.transceivercount;
else
    %  only read GPS data
    transceivercount = 0;
    CIDs = -1;
    nSamples = 0;
    header = config.header;
end

%    TO BE IMPLEMENTED
%  Use this code for identifying channels by their MAC - in conjunction with the
%  channel keyword that will be implemented above.
%
%  extract CID's for transceivers
% nFreqs = length(returnFreqs);
% CIDs = zeros(nFreqs,1);
% for n=1:nFreqs
%     CIDs(n) = str2double(strtok(config.transceiver(n).channelid( ...
%         regexp(config.transceiver(n).channelid, '009072\w*', 'end')+1:end),' '));
% end


%  allocate return structure
data = readEKRaw_AllocateData(transceivercount, config.transceiver, ...
    CHUNK_SIZE, rData, sampleRange, nSamples, userNMEA);

%  allocate array bookkeeping variables
nGPS = uint32(1);
nNMEA = uint32(1);
nVlog = uint32(1);
nVSpeed = uint32(1);
nTAG = uint32(1);
arraySize = zeros(transceivercount, 2, 'uint32');
arraySize(:,1) = CHUNK_SIZE;
arraySize(:,2) = nSamples;
nPings = repmat(uint32(1), 1, transceivercount);
nuNMEA = [length(userNMEA) ones(1, length(userNMEA))];


%  define reader state variables
if isstruct(rparms)
    %  define state variables using provided parameters
    gpsSeg.in = rparms.segState(1);
    gpsSeg.out = rparms.segState(2);
    gpsSeg.inRegion = rparms.inRegion;
    isInRegion = rparms.inRegion;
    pingCounter = rparms.pingnum;
    
    %  insert previous GPS fix
    data.gps.time(nGPS) = rparms.dgTime;
    data.gps.lat(nGPS) = rparms.lat;
    data.gps.lon(nGPS) = rparms.lon;
    if (gpsSeg.inRegion)
        data.gps.seg(nGPS) = gpsSeg.in;
    else
        data.gps.seg(nGPS) = gpsSeg.out;
    end
    nGPS = nGPS + 1;
else
    %  define state variables using defaults
    gpsSeg.in = int16(0);
    gpsSeg.out = int16(0);
    gpsSeg.inRegion = true;
    pingCounter = repmat(uint32(0), 1, transceivercount);
end

%  if continuing - pick up where we left off
if (rData.continue) && (isstruct(rparms))
    fseek(fid, rparms.fpos, 'bof');
end

%  progress callback - determine divisor
if (~isempty(progressCallback))
    wbLast = -1;
    switch true
        case (pingRange(3) ~= Inf)
            wbMode = 1;
            wbMax = (pingRange(3) - pingRange(1)) / pingRange(2);
        case (timeRange(2) ~= Inf)
            wbMode = 2;
            wbMax = timeRange(2) - timeRange(1);
        otherwise
            wbMode = 0;
            cp = ftell(fid);
            fseek(fid, 0 , 'eof');
            wbMax = ftell(fid);
            fseek(fid, cp, 'bof');
    end
end


%  read file, processing individual datagrams
while (true)
    
    %  check if we're at the end of the file
    len = fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end

    %  read datagram header
    [dgType, dgTime] = readEKRaw_ReadDgHeader(fid, timeOffset);
    
    %  if reading subsets - check if we're done
    if (dgTime > timeRange(2))
        %  move file pointer back to beginning of this datagram
        fseek(fid, -(HEADER_LEN + 4), 0);
        break;
    end
    
    %  call progress callback
    if (~isempty(progressCallback))
        %  calculate current position
        switch wbMode
            case 0
                wbCur = ftell(fid);
            case 1
                wbCur = pingCounter(1) - pingRange(1);
            case 2
                wbCur = dgTime - timeRange(1);
        end
        %  calculate normalized progress value
        wbProg = wbCur / wbMax;
        
        %  clamp...
        if (wbProg > 1); wbProg = 1; end
        if (wbProg < 0); wbProg = 0; end
        
        %  are we calling back this iteration?
        wbThis = round(wbProg * 100);
        if (mod(wbThis, progressGranularity) == 0) && (wbThis ~= wbLast)
            % call the progress callback
            progressCallback(wbProg);
            wbLast = wbThis;
        end
    end
    
    %  process datagrams by type
    switch (dgType)

        case 'NME0'
            % Process NMEA datagram

            %  read datagram
            text = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            %  store the raw NMEA text
            if (rData.rawNMEA)
                %  check len of arrays - extend if required
                if (nNMEA > data.NMEA.len)
                    data.NMEA.time = [data.NMEA.time; zeros(CHUNK_SIZE, ...
                        1, 'double')];
                    data.NMEA.string = [data.NMEA.string; cell(CHUNK_SIZE,1)];
                    data.NMEA.len = data.NMEA.len + CHUNK_SIZE;
                end
                
                %  assign raw NMEA data
                data.NMEA.time(nNMEA) = dgTime;
                data.NMEA.string(nNMEA) = {text};
                nNMEA = nNMEA + 1;
            end

            if rData.gps || rData.vlog || rData.vSpeed || rData.uNMEA
            
                %  parse datagram
                [nmea, hasCheck] = readEKRaw_ParseNMEAstring(text, rData, rChecksums);
                
                %  extract datagrams of interest, process and store
                switch true
                    
                    %  GPS Fix data
                    case rData.gps && strcmp(nmea.type, rData.gpsSource)

                        %  check that GPS data has valid fix - drop if not
                        if (nmea.fix == 0)
                            fread(fid, 1, 'int32', 'l');
                            continue;
                        end

                        %  check if this nmea data has checksums and if we're only
                        %  requiring them if the first GPS sentence has them.
                        if (nGPS == 1) && (rGPSChecksums == -1)
                            rChecksums = [hasCheck, hasCheck, rChecksums(3), ...
                                rChecksums(4)];
                        end
                            
                        %  check len of arrays - extend if required
                        if (nGPS > data.gps.len)
                            data.gps.time = [data.gps.time; zeros(CHUNK_SIZE, ...
                                1, 'double')];
                            data.gps.lat = [data.gps.lat; zeros(CHUNK_SIZE, ...
                                1, rData.gpsType)];
                            data.gps.lon = [data.gps.lon; zeros(CHUNK_SIZE, ...
                                1, rData.gpsType)];
                            data.gps.seg = [data.gps.seg; zeros(CHUNK_SIZE, ...
                                1, 'int16')];
                            data.gps.len = data.gps.len + CHUNK_SIZE;
                        end
                        
                        %  set time
                        data.gps.time(nGPS) = dgTime;
                        
                        try
                            %  set lat/lon signs and store values
                            if (nmea.lat_hem == 'S'); 
                                data.gps.lat(nGPS) = -nmea.lat;
                            else
                                data.gps.lat(nGPS) = nmea.lat;
                            end
                            if (nmea.lon_hem == 'W'); 
                                data.gps.lon(nGPS) = -nmea.lon;
                            else
                                data.gps.lon(nGPS) = nmea.lon;
                            end
                        catch
                            %  this GPS sentence must have been lacking data - ignore it.
                            fread(fid, 1, 'int32', 'l');
                            continue;
                        end

                        %  are we limiting data by geographic region?
                        if (rData.doGeo)
                            %  yes - test if fix is in ROI
                            if (geoConn(1) < 0)
                                %  no connectivity provided
                                [isInRegion, bnd] = inpoly([data.gps.lat(nGPS), ...
                                    data.gps.lon(nGPS)], geoRegion);
                            else
                                %  explicit connectivity provided
                                [isInRegion, bnd] = inpoly([data.gps.lat(nGPS), ...
                                    data.gps.lon(nGPS)], geoRegion, geoConn);
                            end
                        else
                            %  no - always "in"
                            isInRegion = true;
                        end

                        %  set prior GPS fix
                        if (nGPS == 1)
                            %  no priors in data.gps
                            if (isstruct(rparms))
                                %  check if the rparms fix is close
                                %  this is a sanity check on the rstat GPS fix
                                dist = vdist(data.gps.lat(nGPS), data.gps.lon(nGPS), ...
                                    rparms.lat, rparms.lon);
                                if dist < MAXRSTATGPSM
                                    % pick up last fix from rparms struct
                                    lastLat = rparms.lat;
                                    lastLon = rparms.lon;
                                else
                                    %  too far apart - replicate first fix
                                    lastLat = data.gps.lat(nGPS);
                                    lastLon = data.gps.lon(nGPS);
                                end
                            else
                                %  no rparms - just replicate first fix
                                lastLat = data.gps.lat(nGPS);
                                lastLon = data.gps.lon(nGPS);
                                
                                %  set initial segment value
                                if (isInRegion)
                                    %  only need to set in state...
                                    gpsSeg.in = 1;
                                end
                            end
                        else
                            %  priors read - assign
                            lastLat = data.gps.lat(nGPS-1);
                            lastLon = data.gps.lon(nGPS-1);
                        end
                        
                        %  check if vessel moved and calculate delta
                        if  (maxSegGap > 0) && ((data.gps.lat(nGPS) - lastLat ~= 0) || ...
                            (data.gps.lon(nGPS) - lastLon ~= 0))

                            %  moved - calculate distance between fixes (in m)
                            dist = vdist(data.gps.lat(nGPS), data.gps.lon(nGPS), ...
                                lastLat, lastLon);
                        else
                            %  no movement
                            dist = 0;
                        end
                        
                        %  determine segment value
                        if (maxSegGap > 0) && (dist > maxSegGap)
                            %  distance exceeds threshold - increment segment
                            if (gpsSeg.inRegion)
                                %  in ROI - increment "in" counter
                                gpsSeg.in = gpsSeg.in + int16(1);
                                data.gps.seg(nGPS) = gpsSeg.in;
                            else
                                %  out of ROI - increment "out" counter
                                gpsSeg.out = gpsSeg.out - int16(1);
                                data.gps.seg(nGPS) = gpsSeg.out;
                            end
                        elseif (rData.doGeo)
                            if (isInRegion)
                                %  in ROI
                                if (~gpsSeg.inRegion)
                                    %  transitioned - increment in counter
                                    gpsSeg.inRegion = true;
                                    gpsSeg.in = gpsSeg.in + int16(1);
                                end
                                data.gps.seg(nGPS) = gpsSeg.in;
                            else
                                %  out of ROI
                                if (gpsSeg.inRegion)
                                    %  transitioned - decrement out counter
                                    gpsSeg.inRegion = false;
                                    gpsSeg.out = gpsSeg.out - int16(1);
                                end
                                data.gps.seg(nGPS) = gpsSeg.out;
                            end
                        else
                            %  not using ROI's or segGap - always in one segment
                            data.gps.seg(nGPS) = gpsSeg.in;
                        end
                        %  increment GPS counter
                        nGPS = nGPS + 1;

                        
                    %  store vessel log data    
                    case rData.vlog && strcmp([rData.vlwSource 'VLW'], nmea.type) && isInRegion

                        %  check len of arrays - extend if required
                        if (nVlog > data.vlog.len)
                            data.vlog.time = [data.vlog.time; zeros(CHUNK_SIZE, 1, 'double')];
                            data.vlog.vlog = [data.vlog.vlog; zeros(CHUNK_SIZE, 1, rData.vlogType)];
                            if (rData.gps)
                                data.vlog.seg = [data.vlog.seg; zeros(CHUNK_SIZE, 1, 'int16')];
                            end
                            data.vlog.len = data.vlog.len + CHUNK_SIZE;
                        end
                        
                        data.vlog.time(nVlog) = dgTime;
                        data.vlog.vlog(nVlog) = nmea.total_cum_dist;
                        if (rData.gps); data.vlog.seg(nVlog) = gpsSeg.in; end
                        nVlog = nVlog + 1;


                    %  store vessel speed data
                    case rData.vSpeed && strcmp([rData.vtgSource 'VTG'], nmea.type) && isInRegion

                        %  check len of arrays - extend if required
                        if (nVSpeed > data.vspeed.len)
                            data.vspeed.time = [data.vspeed.time; zeros(CHUNK_SIZE, 1, 'double')];
                            data.vspeed.speed = [data.vspeed.speed; zeros(CHUNK_SIZE, 1, rData.vSpeedType)];
                            if (rData.gps)
                                data.vspeed.seg = [data.vspeed.seg; zeros(CHUNK_SIZE, 1, 'int16')];
                            end
                            data.vspeed.len = data.vspeed.len + CHUNK_SIZE;
                        end
                        
                        data.vspeed.time(nVSpeed) = dgTime;
                        data.vspeed.speed(nVSpeed) = nmea.sog_knts;
                        data.vspeed.seg(nVSpeed) = gpsSeg.in;
                        nVSpeed = nVSpeed + 1;

                end
                
                %  store user defined NMEA strings
                if rData.uNMEA
                    thisNMEA = strcmpi(nmea.type, userNMEA);
                    nuIDX = [false thisNMEA];
                    if sum(thisNMEA) > 0
                        %  check len of arrays - extend if required
                        if (nuNMEA(nuIDX) > data.NMEA.(userNMEA{thisNMEA}).len)
                            data.NMEA.(userNMEA{thisNMEA}).time = ...
                                [data.NMEA.(userNMEA{thisNMEA}).time; zeros(CHUNK_SIZE, 1, 'double')];
                            data.NMEA.(userNMEA{thisNMEA}).string = ...
                                [data.NMEA.(userNMEA{thisNMEA}).string; cell(CHUNK_SIZE, 1)];
                            data.NMEA.(userNMEA{thisNMEA}).len = ...
                                data.NMEA.(userNMEA{thisNMEA}).len + CHUNK_SIZE;
                        end

                        data.NMEA.(userNMEA{thisNMEA}).time(nuNMEA(nuIDX)) = dgTime;
                        data.NMEA.(userNMEA{thisNMEA}).string(nuNMEA(nuIDX)) = {text};
                        nuNMEA(nuIDX) = nuNMEA(nuIDX) + 1;
                    end
                end
                
            end
            lastType = dgType;

        case 'TAG0'
            %  Process annotation datagram
            text = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            if (rData.annotations)
                %  check len of arrays - extend if required
                if (nTAG > data.annotations.len)
                    data.annotations.time = [data.annotations.time; zeros(CHUNK_SIZE, 1, 'double')];
                    data.annotations.text = [data.annotations.text; cell(CHUNK_SIZE, 1)];
                    data.annotations.len = data.annotations.len + CHUNK_SIZE;
                end

                data.annotations.time(nTAG) = dgTime;
                data.annotations.text(nTAG) = {text};
                nTAG = nTAG + 1;
            end
            lastType = dgType;

        case 'RAW0'
            %  Process sample datagram
            if (CIDs(1) > 0)
                sampledata = readEKRaw_ReadSampledata(fid, sampledata);
                idx = find(CIDs == sampledata.channel);
            else
                idx = [];
                fread(fid, len - HEADER_LEN, 'char', 'l');
            end

            %  check if we're storing this frequency...
            if (~isempty(idx)) 
                
                %  check if the beam mode has changed if we're enforcing a strict beam mode
                if ~allowBeamModeChange
                    if  (beamMode < 0) && (sampledata.mode > 0)
                        %  set the initial beam mode - but only if we have a valid mode
                        beamMode = sampledata.mode;
                    else
                        %  check if it has changed (though ignore 0 mode data)
                        if (beamMode ~= sampledata.mode) && (sampledata.mode > 0)
                            error('readEKRaw:ModeChange', ['Tsk. Tsk. Tsk. Your beam mode has changed. ' ...
                                  'Set the AllowModeChange parameter to true to read this file.']);
                        end
                    end
                end
                
                %  increment total ping counter
                pingCounter(idx) = pingCounter(idx) + 1;
                
                %  if reading subsets - check if we're done
                if (pingCounter(idx) > pingRange(3))
                    %  move file pointer back to beginning of this datagram
                    fseek(fid, -(len + 4), 0);
                    %  tick back ping counter
                    pingCounter(idx) = pingCounter(idx) - 1;
                    break;
                end
                
                %  check if we're storing this ping...
                if (pingCounter(idx) >= pingRange(1)) && (dgTime >= timeRange(1)) &&...
                    (isInRegion) && (~mod(pingCounter(idx), pingRange(2)))
                
                    %  check length of arrays - extend if required
                    if (nPings(idx) > arraySize(idx,1))
                        arraySize(idx,1) = arraySize(idx,1) + CHUNK_SIZE;
                        data.pings(idx).number(1, nPings(idx):arraySize(idx,1)) = 0;
                        data.pings(idx).time(1, nPings(idx):arraySize(idx,1)) = 0;
                        if (~rData.skinny)
                            data.pings(idx).mode(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).transducerdepth(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).frequency(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).transmitpower(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).pulselength(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).bandwidth(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).sampleinterval(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).soundvelocity(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).absorptioncoefficient(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).offset(1, nPings(idx):arraySize(idx,1)) = 0;
                        end
                        if (rData.heave); data.pings(idx).heave(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.roll); data.pings(idx).roll(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.pitch); data.pings(idx).pitch(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.temp); data.pings(idx).temperature(1, nPings(idx):arraySize(idx,1)) = 0; end
                        if (rData.trawl)
                            data.pings(idx).trawlopeningvalid(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).trawlupperdepthvalid(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).trawlupperdepth(1, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).trawlopening(1, nPings(idx):arraySize(idx,1)) = 0;
                        end
                        data.pings(idx).count(1, nPings(idx):arraySize(idx,1)) = 0;
                        if (rData.power) && (beamMode ~= 2)
                            data.pings(idx).power(:, nPings(idx):arraySize(idx,1)) = -999;
                        end
                        if (rData.angle) && ((beamMode > 1) || (beamMode < 0))
                            data.pings(idx).alongship_e(:, nPings(idx):arraySize(idx,1)) = 0;
                            data.pings(idx).athwartship_e(:, nPings(idx):arraySize(idx,1)) = 0;
                        end
                        if (rData.gps); data.pings(idx).seg(1, nPings(idx):arraySize(idx,1)) = 0; end
                    end
                    
                    %  copy this pings data into output arrays
                    data.pings(idx).number(nPings(idx)) = pingCounter(idx);
                    data.pings(idx).time(nPings(idx)) = dgTime;

                    if (rData.skinny > 0)
                        if (rData.skinny == nPings(idx))
                            %  operating in "skinny" mode and this is the ping we
                            %  want to read our parameters from.
                            data.pings(idx).mode(1) = ...
                                sampledata.mode;
                            data.pings(idx).transducerdepth(1) = ...
                                sampledata.transducerdepth;
                            data.pings(idx).frequency(1) = ...
                                sampledata.frequency;
                            data.pings(idx).transmitpower(1) = ...
                                sampledata.transmitpower;
                            data.pings(idx).pulselength(1) = ...
                                sampledata.pulselength;
                            data.pings(idx).bandwidth(1) = ...
                                sampledata.bandwidth;
                            data.pings(idx).sampleinterval(1) = ...
                                sampledata.sampleinterval;
                            data.pings(idx).soundvelocity(1) = ...
                                sampledata.soundvelocity;
                            data.pings(idx).absorptioncoefficient(1) = ...
                                sampledata.absorptioncoefficient;
                            data.pings(idx).offset(1) = ...
                                sampledata.offset;
                        end
                    else
                        %  operating in "fat" mode.  Store all parameters.
                        data.pings(idx).mode(nPings(idx)) = ...
                            sampledata.mode;
                        data.pings(idx).transducerdepth(nPings(idx)) = ...
                            sampledata.transducerdepth;
                        data.pings(idx).frequency(nPings(idx)) = ...
                            sampledata.frequency;
                        data.pings(idx).transmitpower(nPings(idx)) = ...
                            sampledata.transmitpower;
                        data.pings(idx).pulselength(nPings(idx)) = ...
                            sampledata.pulselength;
                        data.pings(idx).bandwidth(nPings(idx)) = ...
                            sampledata.bandwidth;
                        data.pings(idx).sampleinterval(nPings(idx)) = ...
                            sampledata.sampleinterval;
                        data.pings(idx).soundvelocity(nPings(idx)) = ...
                            sampledata.soundvelocity;
                        data.pings(idx).absorptioncoefficient(nPings(idx)) = ...
                            sampledata.absorptioncoefficient;
                        data.pings(idx).offset(nPings(idx)) = ...
                            sampledata.offset;
                    end
                    if (rData.heave); data.pings(idx).heave(nPings(idx)) = ...
                        sampledata.heave; end
                    if (rData.roll); data.pings(idx).roll(nPings(idx)) = ...
                        sampledata.roll; end
                    if (rData.pitch); data.pings(idx).pitch(nPings(idx)) = ...
                        sampledata.pitch; end
                    if (rData.temp); data.pings(idx).temperature(nPings(idx)) = ...
                        sampledata.temperature; end
                    if (rData.trawl)
                        data.pings(idx).trawlopeningvalid(nPings(idx)) = ...
                            sampledata.trawlopeningvalid;
                        data.pings(idx).trawlupperdepthvalid(nPings(idx)) = ...
                            sampledata.trawlupperdepthvalid;
                        data.pings(idx).trawlupperdepth(nPings(idx)) = ...
                            sampledata.trawlupperdepth;
                        data.pings(idx).trawlopening(nPings(idx)) = ...
                            sampledata.trawlopening;
                    end
                    
                    %  store sample data
                    if (sampledata.count > 0)
                        %  handle "subsettable" data
                        if (sampleRange(1) <= sampledata.count)
                            %  determine ending sample index
                            if (sampleRange(2) > sampledata.count)
                                endIdx = sampledata.count;
                                %  cap number of data samples stored to maxSampleRange
                                if endIdx > maxSampleRange; endIdx = maxSampleRange; end
                            else
                                endIdx = sampleRange(2);
                            end
                            %  store actual sample count value
                            count = (endIdx - sampleRange(1)) + 1;
                            data.pings(idx).count(nPings(idx)) = count;

                            %  check depth of arrays - extend if required
                            if (arraySize(idx,2) < count)
                                nSampAdd = count - uint16(arraySize(idx,2));
                                data.pings(idx).samplerange(2) = count;
                                if (rData.power)
                                    data.pings(idx).power(end + 1:end + nSampAdd,:) = -999;
                                end
                                if (rData.angle)
                                    data.pings(idx).alongship_e(end + 1:end + nSampAdd,:) = 0;
                                    data.pings(idx).athwartship_e(end + 1:end + nSampAdd,:) = 0;
                                end
                                arraySize(idx,2) = count;
                            end

                            if (rData.power) && (sampledata.mode ~= 2)
                                %  store power
                                data.pings(idx).power(1:count, nPings(idx)) = ...
                                    sampledata.power(sampleRange(1):endIdx);
                            end
                            if (rData.angle) && (sampledata.mode > 1)
                                %  store angles
                                data.pings(idx).alongship_e(1:count, nPings(idx)) = ...
                                    sampledata.alongship(sampleRange(1):endIdx);
                                data.pings(idx).athwartship_e(1:count, nPings(idx)) = ...
                                    sampledata.athwartship(sampleRange(1):endIdx);
                            end
                        end
                    else
                        data.pings(idx).count(nPings(idx)) = 0;
                    end

                    %  store GPS line segment value
                    if (rData.gps)
                        data.pings(idx).seg(nPings(idx)) = gpsSeg.in;
                    end
                    
                    %  increment stored ping counter
                    nPings(idx) = nPings(idx) + 1;
                end
            end
            lastIDX = idx;
            lastType = dgType;

        case 'CON1'
            %  Read ME70 CON datagram
            conTextRaw = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            %  At some point this may return a data structure containing
            %  the parameters defined in the CON1 datagram but currently
            %  only the text contained in the datagram is returned.
            %
            %  The CON1 XML string is non-conformant in that the values for
            %  each node are stored within the opening tag as "value"
            %  instead of between the opening and closing tag.
            %
            %  Most XML packages do not parse this correctly. A custom parser
            %  needs to be written to return a sane structure containing the
            %  CON1 data.
            
            %conText = conText(regexp(conTextRaw, '?>\r\n<', 'end'):end - 2);

            %  return configuration data as a char array
            data.conf.time = dgTime;
            data.conf.text = conTextRaw;
            lastType = dgType;
            
        case 'SVP0'
            %  Read Sound Velocity Profile datagram
            svpText = char(fread(fid, len - HEADER_LEN, 'char', 'l')');
            
            % this datagram is not handled at this time.
            % Bjarte Berntsen (Kongsberg) has provided the format and I
            % will incorporate this at some point in the future.
            
            lastType = dgType;
            
        % Process unknown datagrams
        otherwise
            if (maxBadBytes > 0)
                %  Display warning - try to find next datagram
                warning('readEKRaw:Datagram', ['Invalid datagram at offset ' num2str(ftell(fid)) ...
                    '(d) - Searching for next datagram...']);

                %  rewind to last good dgram header
                fseek(fid, -(lastLen + 8), 0);

                ok = false;
                nBytes = 0;
                while (~ok)
                    try
                        %  read 4 bytes and look for known datagram
                        dgType = char(fread(fid,4,'char', 'l')');
                    catch
                        warning('readEKRaw:Datagram', 'Unable to locate next valid datagram.');
                        break;
                    end
                    nBytes = nBytes + 4;
                    if (strcmp(dgType, 'CON1') || strcmp(dgType, 'RAW0') || ...
                            strcmp(dgType ,'TAG0') || strcmp(dgType ,'NME0') || ...
                            strcmp(dgType, 'SVP0'))
                        %  if found w/in last datagram, last datagram is malformed
                        if (nBytes < (lastLen - 8)) && (strcmp(lastType, 'RAW0'))
                            %  only need to drop bad RAW0 datagrams
                            nPings(lastIDX) = nPings(lastIDX) - 1;
                        end
                        %  rewind to beginning of datagram
                        fseek(fid, -12, 0);
                        ok = true;
                    else
                        %  rewind 3 bytes
                        fseek(fid, -3, 0);
                        nBytes = nBytes - 3;
                        %  check if we're giving up
                        if (nBytes > maxBadBytes); 
                            warning('readEKRaw:Datagram', ['Unable to locate valid datagram.' ...
                                ' Giving up.']);
                            break;
                        end
                    end
                end
                if (~ok); break; end
            else
                warning('readEKRaw:Datagram', ['Invalid datagram at offset ' num2str(ftell(fid)) ...
                    '(d) - Aborting...']);
                break;
            end
            
    end
    
    %  datagram length is repeated...
    lastLen = fread(fid, 1, 'int32', 'l');
    
end

%  set the readerState return parameters
if (nargout == 3)
    rp.fpos = ftell(fid);
    rp.pingnum = pingCounter;
    if (rData.gps) && (nGPS > 1)
        rp.segState = [gpsSeg.in, gpsSeg.out];
        rp.inRegion = gpsSeg.inRegion;
        rp.lat = data.gps.lat(nGPS-1);
        rp.lon = data.gps.lon(nGPS-1);
        rp.dgTime = dgTime;
    else
        rp.segState = [0, 0];
        rp.inRegion = true;
        rp.lat = -1;
        rp.lon = -1;
    end
    varargout = {rp};
end

%  close file.
fclose(fid);

%  trim GPS/vlog/vspeed/annotation arrays
if (rData.gps)
    data.gps.time = data.gps.time(1:nGPS-1);
    data.gps.lat = data.gps.lat(1:nGPS-1);
    data.gps.lon = data.gps.lon(1:nGPS-1);
    data.gps.seg = data.gps.seg(1:nGPS-1);
    data.gps = rmfield(data.gps, 'len');
end
if (rData.vlog)
    data.vlog.time = data.vlog.time(1:nVlog-1);
    data.vlog.vlog = data.vlog.vlog(1:nVlog-1);
    if (rData.gps); data.vlog.seg = data.vlog.seg(1:nVlog-1); end
    data.vlog = rmfield(data.vlog, 'len');
end
if (rData.vSpeed)
    data.vspeed.time = data.vspeed.time(1:nVSpeed-1);
    data.vspeed.speed = data.vspeed.speed(1:nVSpeed-1);
    if (rData.gps); data.vspeed.seg = data.vspeed.seg(1:nVSpeed-1); end
    data.vspeed = rmfield(data.vspeed, 'len');
end
if (rData.annotations)
    data.annotations.time = data.annotations.time(1:nTAG-1);
    data.annotations.text = data.annotations.text(1:nTAG-1);
    data.annotations = rmfield(data.annotations, 'len');
end
if (rData.rawNMEA)
    data.NMEA.time = data.NMEA.time(1:nNMEA-1);
    data.NMEA.string = data.NMEA.string(1:nNMEA-1);
    data.NMEA = rmfield(data.NMEA, 'len');
end
if (rData.uNMEA)
    for n=1:nuNMEA(1)
        data.NMEA.(userNMEA{n}).time = data.NMEA.(userNMEA{n}).time(1:nuNMEA(n+1)-1);
        data.NMEA.(userNMEA{n}).string = data.NMEA.(userNMEA{n}).string(1:nuNMEA(n+1)-1);
        data.NMEA.(userNMEA{n}) = rmfield(data.NMEA.(userNMEA{n}), 'len');
    end
end

%  for each transducer...
for idx=1:transceivercount
    if (nPings(idx) <= arraySize(idx,1))
        %  Trim output data arrays
        data.pings(idx).number(nPings(idx):end) = [];
        data.pings(idx).time(nPings(idx):end) = [];
        if (~rData.skinny)
            data.pings(idx).mode(nPings(idx):end) = [];
            data.pings(idx).transducerdepth(nPings(idx):end) = [];
            data.pings(idx).frequency(nPings(idx):end) = [];
            data.pings(idx).transmitpower(nPings(idx):end) = [];
            data.pings(idx).pulselength(nPings(idx):end) = [];
            data.pings(idx).bandwidth(nPings(idx):end) = [];
            data.pings(idx).sampleinterval(nPings(idx):end) = [];
            data.pings(idx).soundvelocity(nPings(idx):end) = [];
            data.pings(idx).absorptioncoefficient(nPings(idx):end) = [];
            data.pings(idx).offset(nPings(idx):end) = [];
        end
        if (rData.heave); data.pings(idx).heave(nPings(idx):end) = []; end
        if (rData.roll); data.pings(idx).roll(nPings(idx):end) = []; end
        if (rData.pitch); data.pings(idx).pitch(nPings(idx):end) = []; end
        if (rData.temp); data.pings(idx).temperature(nPings(idx):end) = []; end
        if (rData.trawl)
            data.pings(idx).trawlopeningvalid(nPings(idx):end) = [];
            data.pings(idx).trawlupperdepthvalid(nPings(idx):end) = [];
            data.pings(idx).trawlupperdepth(nPings(idx):end) = [];
            data.pings(idx).trawlopening(nPings(idx):end) = [];
        end
        if (rData.gps); data.pings(idx).seg(nPings(idx):end) = []; end
        data.pings(idx).count(nPings(idx):end) = [];
        if (rData.power) && (beamMode ~= 2)
            data.pings(idx).power(:, nPings(idx):end) = [];
        end
        if (rData.angle) && ((beamMode > 1) || (beamMode < 0))
            data.pings(idx).alongship_e(:, nPings(idx):end) = [];
            data.pings(idx).athwartship_e(:, nPings(idx):end) = [];
        end
    end    
end

%  remove empty power or angle fields
if (rData.power) && (beamMode == 2)
    %  this beam mode contains no power data - remove the power field
    data.pings = rmfield(data.pings, 'power');
end
if (rData.angle) && (beamMode == 1)
    %  this beam mode contains no angle data - remove the angle fields
    data.pings = rmfield(data.pings, 'alongship_e');
    data.pings = rmfield(data.pings, 'athwartship_e');
end

    
    
