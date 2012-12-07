function A04ExtractPV
    
    % PV = Particle Velocity
    
    %
    
    dataDir = 'q:\collpen\data\201112 Austevoll\Hydrophones\converted_data_files';
    load(fullfile('..', 'results', 'A03CalculateSL_experiments'), 'experiments')
    
    % channels 5 and 13 are the PV hydrophones

    
    calibration = ones(16,1) * 5; % NTNU hydrophones [Pa/V]
    calibration(5)  = 10.5504; % IMR hydrophones [Pa/V]
    calibration(13) = 11.346; % IMR hydrophones [Pa/V]
    
    range(5) = sqrt(mean([82, 86.7])^2 + 4.^2);
    range(13) = range(5); % not quite right
    
    separation = 1.02; % hydrohpone separation [m]
    
    sal = 32; % [PSU]
    temp = 10; % [degC]
    density = sw_dens(sal, temp, 1); % water density, [kg/m^3]
    
    % In the first instance, we'll look at experiment 1, where the
    % hydrophones were parallel to the direction of sound propagation

    exp_i = 3;
    sig_i = 4; % 200 kHz signal
    chan1 = 5;
    chan2 = 13;

    for exp_i = 6 %[3:8 10:16]
        load(fullfile(dataDir, experiments(exp_i).file), 'data')
        fs = data.sample_rate(chan1);
        f_sig = experiments(exp_i).signal(sig_i).freq;
        
        data_start_i = floor((experiments(exp_i).signal(sig_i).start_time+1) * fs);
        data_stop_i = ceil((experiments(exp_i).signal(sig_i).stop_time-1) * fs);

        % the raw signals from the hydrophones
        sig1 = data.values(data_start_i:data_stop_i, chan1);
        sig2 = data.values(data_start_i:data_stop_i, chan2);
        
        % calibrated
        sig1 = sig1 * calibration(chan1);
        sig2 = sig2 * calibration(chan2);
        
        % bandpass filter
        Hd = bandpass_filter(f_sig);
        sig1f = filter(Hd.Numerator, 1, sig1);
        sig2f = filter(Hd.Numerator, 1, sig2);
        
        % spreading loss
        % do this later...
        
        % calculate the particle acceleration
        pres_grad = (sig1f - sig2f) / separation;
        acc = rms(pres_grad / (-density));
        disp(['Particle velocity for ' experiments(exp_i).file ' = ' num2str(acc) ' m/s^2'])
    end
end