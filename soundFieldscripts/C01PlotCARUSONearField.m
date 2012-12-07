%%

% produce a plot of the near-field of the CARUSO transducer

c = 1500; % sound speed [m/s]
r = 0.15; % radius of transducer face, from CARUSO documentation [m]

f = 1:1:1000; % range of frequencies [Hz]

clf

% the pressure decay near field
nf = 4*r*r*f/c;
plot(f, nf, 'k--', 'LineWidth', 2)
hold on

% dipole far-field (where local flow particle motion equals those from the
% the propogating sound wave): lambda/pi
lambda = c./f;
plot(f, lambda/pi, 'k:',  'LineWidth', 2)

% monopole far-field (where local flow particle motion equals those from the
% the propogating sound wave): lambda/2pi
plot(f, lambda/(2*pi), 'k-.',  'LineWidth', 2)


% source looks like a point source
plot(f, 10*r, 'r-', 'LineWidth', 2)

hold off

%ylim([0 10])
set(gca, 'YScale', 'log')
set(gca,'YTickLabel', num2str(get(gca, 'YTick')'))

set(gca, 'XScale', 'log')
set(gca,'XTickLabel', num2str(get(gca, 'XTick')'))

grid on
xlabel('Freq (Hz)')
ylabel('Near field range (m)')

legend('P(R) \propto 1/R', 'local flow = acoustic flow, dipole, on axis', ...
    'local flow = acoustic flow, monopole & kR = 1', 'd = 10r (point source)')

print('-dpng', '-r300', '../results/C01PlotCARUSONearField.png')