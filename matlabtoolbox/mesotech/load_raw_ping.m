% [HEADER REF_PULSE RAW_DATA PING_FOUND] = LOAD_RAW_PING(FILENAME, PING_NUMBER, OPTIONS)
%
%   Loads raw for ping with ping counter equal to PING_NUMBER (if found)
%
%   FILENAME    - .mmb path and filename
%   PING_NUMBER - ping count of requested ping
%   OPTIONS     - struct with fields
%                   .sequential_pings = 0 or 1, default 1, set to 0 for
%                                       exhaustive search (slower)
%                   .verbose = 0 or 1, default 0, set to 1 to show messages
%                              during search
%
%   HEADER      - Struct containing header data from the raw data file
%   REF_PULSE   - Reference pulse for range compression
%   RAW_DATA    - M by N matrix of complex raw samples, where M is the
%                 number of samples per rangeline and N is the number of
%                 elements
%   PING_FOUND  - 0 or 1, 1 if ping found

function [header ref_pulse raw_data ping_found] = load_raw_ping(filename, ping_number, options)

if ~isfield(options, 'sequential_pings')
    options.sequential_pings = 1;
end

if ~isfield(options, 'verbose')
    options.verbose = 1;
end

ping_found = 0;
ping_i = 0;
header = [];
ref_pulse = [];
raw_data = [];

done = 0;

while ~done
    try
        [header ref_pulse raw_data] = load_raw_data(filename, ping_i);
        
        if options.verbose
            disp([filename '; ping_i = ' num2str(ping_i) '; Ping Counter = ' num2str(header.Ping_Counter)]);
        end
        
        if header.Ping_Counter == ping_number
            ping_found = 1;
            done = 1;
        else
            if options.sequential_pings
                if ping_number < header.Ping_Counter
                    ping_found = 0;
                    done = 1;
                else
                    delta_ping = floor((ping_number - header.Ping_Counter)/4);
                    ping_i = ping_i + max(delta_ping, 1);
                end
            else
                % Not necessarily sequential -- search every ping
                ping_i = ping_i + 1;
            end
        end
    catch
        %err = lasterror;
        %disp(['Error occurred (last error = ' err.message ')']);
        done = 1;
    end
    
    if options.sequential_pings
        if ping_i >= ping_number
            done = 1;
        end
    end
end

if ping_found
    if options.verbose
        disp(['Ping ' num2str(header.Ping_Counter) ' found!']);
    end
else
    if options.verbose
        disp(['Ping ' num2str(ping_number) ' not found!']);
    end
    header = [];
    ref_pulse = [];
    raw_data = [];
end
    