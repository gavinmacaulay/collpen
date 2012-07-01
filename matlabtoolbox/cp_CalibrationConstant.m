function [scaleFactor ampGain carusoCurrent] = cp_CalibrationConstant(f, SPL, R)

    % Inputs:
    % f, the frequencies to estimate the system settings for [Hz]
    % SPL, the required SPL [dB re 1uPa]
    % R, the range for the SPL [m]
    % 
    % Outputs:
    % scaleFactor, the factor to scale the voltage input to the amp
    % ampGain, the amplifier gain to use
    % carusoCurrent, the current to use on the magnetising coil in CARUSO
    
    % Wishlist for Gavin
    % 3 - testrun it on the tonetreatmentblocl script.
  
    % Some constants related to the calibration
    calFreq = [80 150 225 300 400 600 750 900 1000 1250 1500];

    availableGains = [0:-1:-13 -15 -17 -19 -22 -29 -54 -80];
    
    calToUse = 'NTNU'; % 'NTNU' or 'PV'
    

    if strcmp(calToUse, 'NTNU')
        ampGainRef = -10;
        calCurrent = 4; % [A]
        calSL = [162.2637
            178.8809
            177.6352
            180.0815
            178.7463
            177.2745
            176.2 %180.1863
            175.3353
            175.7558
            170.0725
            169.5239
            ];
    else            
        % Another calibration - done during PVexp
        ampGainRef = -17;
        calCurrent = 6; % [A]
        calSL = [     146.1367
            167.2366
            165.7587
            163.2661
            162.0586
            166.3345
            163.6635
            160.9884
            163.1487
            161.4420
            172.9576
            ];
    end

    
    TL = 20*log10(R); % transmission loss for the given range
    SLf = interp1(calFreq, calSL, f); % SL at the desired frequencies, 
                                   % interpolated from the calibrated SL.
    
    ampGain = ampGainRef * ones(size(f));
    carusoCurrent = calCurrent * ones(size(f));
    
    % Quick and dirty vectorisation on f...
    for j = 1:length(f)
        % the SPLs at the given range, reference amp gain, and current
        SPLf = SLf(j) - TL;
        
        % how much we need to change the SL by to achieve the requested SPL
        diffSPL = SPL - SPLf;
        % the change in signal in linear units. XXX But, is the amp gain
        % dial in volts or power???? XXXXXXXXXXXX
        
        % Use 20 if amp gain is for volts. This gives us a scale factor for
        % pressure, and hence volts.
        scaleFactor(j) = 10.^(diffSPL/20); 
        
        % We now have a scaleFactor at the calibrated amp gain. We want to
        % maximise the scaleFactor (but keep it <= 1) so now look at adjusting
        % the amp gain setting to do this.
        
        % what changes in amp gain are possible, relative to the calibrated?
        gainChange = availableGains - ampGainRef;
        % and what would the scale factors be if we used these possible amp
        % gains?
        availableScaleFactors = scaleFactor(j) ./ 10.^(gainChange/10);
        % sanity checks - can't do anything if newScaleFactor is all above 1 -
        % we have asked for a SPL that is too loud.
        if min(availableScaleFactors) > 1
            disp('Requested SPL is too large - reduce range.')
            scaleFactor(j) = NaN;
        else
            % choose the largest scale factor that is <= 1
            i = find(availableScaleFactors <= 1);
            i = i(end);
            scaleFactor(j) = availableScaleFactors(i);
            ampGain(j) = availableGains(i);
        end
    end
    
    % But, we need the same ampGain for all frequencies, so adjust for that.
    % Choose the maximum ampGain and adjust the scaleFactor to achieve the
    % desired SPL.
    newAmpGain = max(ampGain);
    changeInAmpGain = ampGain - newAmpGain;
    scaleFactor = scaleFactor .* 10 .^(changeInAmpGain/10);
    
    ampGain = newAmpGain * ones(size(f));
    

