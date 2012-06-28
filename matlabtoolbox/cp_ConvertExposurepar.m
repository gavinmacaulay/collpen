function cp_ConvertExposurepar(path,file)
    
    % Convert the exposureparameter used to generate the tones in the
    % exposure experiment 
    load(fullfile(path,file))
    
    % Convert to "human" time
    if isfield(par,'treat_start')
    [par.treat_startyear,par.treat_startmonth,par.treat_startday,par.treat_starthour,par.treat_startmin,par.treat_startsek]=datevec(par.treat_start)
    end
    
    if isfield(par,'treat_stop')
    [par.treat_stopyear,par.treat_stopmonth,par.treat_stopday,par.treat_stophour,par.treat_stopmin,par.treat_stopsek]=datevec(par.treat_stop)
    end
    
    % Par is the file
     xml_write(fullfile(path,[file,'.xml']), par, file)
end

