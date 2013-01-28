%%
% some globals. Run this cell before the ones below.
datadir1 = '..\..\callisto\AustevollExp\data\NTNUtrials\ctd';
datadir2 = '..\..\callisto\AustevollExp\data\NTNUexp\ctd';
resultsdir = '..\..\results';

%%
% Plot the data from the CTD casts

dhut = txt2struct(fullfile(datadir1, '20111207 cast at hut with salinity.txt'), 'skiplines', 3, 'delimiter', ';');
i = find(dhut.Press > 0.5);

clf
subplot(1,2,1)
[ax1, ax2] = plotxx(dhut.Temp(i), dhut.Press(i), dhut.Sal(i), dhut.Press(i));
set(ax1, 'Ydir','reverse')
set(ax2, 'Ydir','reverse')
ylabel(ax1, 'Depth (m)')
ylabel(ax2, 'Depth (m)')
xlabel(ax1, 'Temperature (\circC)')
xlabel(ax2, 'Salinity (PSU)')

subplot(1,2,2)
plot(dhut.SVel(i), dhut.Press(i))
set(gca, 'Ydir', 'reverse')
ylabel('Depth (m)')
xlabel('Sound speed (m/s)')


print('-dpng','-r300',fullfile(resultsdir, 'B01ShowCTDs 20111207 cast at hut'))

%%
dseries = txt2struct(fullfile(datadir1, '20111208 series with salinity.txt'), 'skiplines', 8, 'delimiter', ';');

i = find(dseries.Press >= 0.5);

clf
subplot(1,2,1)
[ax1, ax2, hl1, hl2] = plotxx(dseries.Temp(i), dseries.Press(i), dseries.Sal(i), dseries.Press(i));
set(ax1, 'Ydir','reverse')
set(ax2, 'Ydir','reverse')
ylabel(ax1, 'Depth (m)')
ylabel(ax2, 'Depth (m)')
xlabel(ax1, 'Temperature (\circC)')
xlabel(ax2, 'Salinity (PSU)')


subplot(1,2,2)
plot(dseries.SVel(i), dseries.Press(i))
set(gca, 'Ydir', 'reverse')
ylabel('Depth (m)')
xlabel('Sound speed (m/s)')

print('-dpng','-r300',fullfile(resultsdir, 'B01ShowCTDs 20111207 series'))

%%
names = dir(fullfile(datadir2, '*.txt'));

for j = 1:length(names)
    
    dseries = txt2struct(fullfile(datadir2, names(j).name), 'skiplines', 3, 'delimiter', ';');

    i = find(dseries.Press >= 0.5);
    
    clf
    subplot(1,2,1)
    [ax1, ax2, hl1, hl2] = plotxx(dseries.Temp(i), dseries.Press(i), dseries.Sal(i), dseries.Press(i));
    set(ax1, 'Ydir','reverse')
    set(ax2, 'Ydir','reverse')
    ylabel(ax1, 'Depth (m)')
    ylabel(ax2, 'Depth (m)')
    xlabel(ax1, 'Temperature (\circC)')
    xlabel(ax2, 'Salinity (PSU)')
    
    
    subplot(1,2,2)
    plot(dseries.SVel(i), dseries.Press(i))
    set(gca, 'Ydir', 'reverse')
    ylabel('Depth (m)')
    xlabel('Sound speed (m/s)')
    
    [~, name, ~] = fileparts(names(j).name);
    print('-dpng','-r300',fullfile(resultsdir, ['B01ShowCTDs_' name '.png']))
end
