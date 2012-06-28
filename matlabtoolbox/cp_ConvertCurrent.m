function cp_ConvertCurrent(dataDir)
    
    % Convert to read the data files created by the Aligent GUI datalogger
    % software. 
    
    % For CollPen we are only interested in the current, so ignore other
    % measurements.
    
    d = dir(fullfile(dataDir, '*.csv'));
    
    for i = 1:length(d)
       d(i).name 
       
    end
end