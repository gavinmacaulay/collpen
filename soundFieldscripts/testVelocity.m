%function testVelocity(d)
    
    %%
    
    h1 = d.sampledata(:,5);
    h2 = d.sampledata(:,13);
    
    clf
    subplot(2,1,1)
    plot(h1)
    ylim([-.5 .5])
    subplot(2,1,2)
    plot(h2)
    ylim([-.5 .5])
    
    %%
    % choose a signal of interest
    h1p = h1(5e5:6.1e5);
    h2p = h2(5e5:6.1e5);

    %h1p = h1(3e5:4e5);
    %h2p = h2(3e5:4e5);

    clf
    subplot(2,1,1)
    plot(h1p)
    hold on
    plot(h2p, 'r')
    ylim([-.5 .5])
    
    separation = 1.05; % hydrophone separation [m]
    c = 1490; % sound speed [m/s]
    rho = 1025; % water density [kg/m^3]

    dpdt = (h1p - h2p) / separation;
    dudt = dpdt / (-rho);
    
    subplot(2,1,2)
    plot(dudt)
    rms = sqrt(mean(dudt.*dudt))
    %ylim([-2 2]*1e-4)
    
    %%
    % work with filtered data
    clf
    subplot(2,1,1)
    plot(h1p_filtered.data)
    hold on
    plot(h2p_filtered.data,'r')    
    ylim([-.5 .5])
    

    separation = 1.05; % hydrophone separation [m]
    c = 1490; % sound speed [m/s]
    rho = 1025; % water density [kg/m^3]
    dpdt = (h1p_filtered.data - h2p_filtered.data) / separation;
    
    dudt = dpdt / (-rho);
    subplot(2,1,2)
    plot(dudt)
    rms = sqrt(mean(dudt.*dudt))
    
%end