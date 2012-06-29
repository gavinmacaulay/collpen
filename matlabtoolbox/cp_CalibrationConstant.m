function [scaleFactor ampGain CarusoCurrent] = cp_CalibrationConstant(f, SPL, R, fixedAmpGain)

% Wishlist for Gavin
% 1 - Input should be vectorized on frequency to be able to apply it on a chirp. 
% 2 - Outputs needs to be cosntant, that current and ampgain.
% 3 - testrun it on the tonetreatmentblocl script.
% 4 - Update it with the new calibration stuff
% 5 - Optimize for maximum scalefactor ~1 in order to have a decent SNR

    freq = [80 150 225 300 400 600 750 900 1000 1250 1500];
    ampGainRef = -10;
    availableGains = [0:-1:-13 -15 -17 -19 -22 -29 -54 -80];
    
    if nargin == 3
        fixedAmpGain = NaN;
    else
        i = find(availableGains == fixedAmpGain);
        if isempty(i)
            disp(['The fixedAmpGain parameter must be one of these values: ' ...
                num2str(availableGains)])
            return
        end
    end
    
    
    SL = [162.2637
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
    
    TL = 20*log10(R);
    SLf = interp1(freq, SL, f);
    
    % the SPL at the given range and reference amp gain
    SPLf = SLf - TL;
    
    diffSPL = SPL - SPLf;
    scaleFactor = 10.^(diffSPL/10);
    ampGain = ampGainRef;
    
    if ~isnan(fixedAmpGain)
        % calc scale factor without adjusting the amp gain
        diffSPL = SPL - SPLf - (fixedAmpGain - ampGainRef);
        scaleFactor = 10.^(diffSPL/10);
        ampGain = fixedAmpGain;
    else
        if scaleFactor > 1 % need to increase the amp gain
            % only work with the possible amp gains
            gainChange = availableGains - ampGainRef;
            newScaleFactors = scaleFactor * 10.^(gainChange/10);
            % choose the scale factor that is closest to one
            [~, i] = max(newScaleFactors);
            scaleFactor = newScaleFactors(i);
            ampGain = availableGains(i);
        end
        if scaleFactor < 1e-5 % decrease the amp gain
            % only work with the possible amp gains
            gainChange = availableGains - ampGainRef;
            newScaleFactors = scaleFactor ./ 10.^(gainChange/10);
            % choose the scale factor that is closest to one, but less than
            % one
            i = find(newScaleFactors <= 1);
            i = i(end);
            scaleFactor = newScaleFactors(i);
            ampGain = availableGains(i);
        end
    end
    
    if scaleFactor > 1
        disp(['Requested SPL is too large.'])
    end
end

