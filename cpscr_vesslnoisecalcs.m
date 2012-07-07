% script to document logic in setting ship noise levels
%
%

% SPL's for JH and GOS based on ONA et al filtered from 50-2000 Hz
% see cpscr_vesselnoisetreatmentblock.m
%  parameters
jh.SL=171.7; % SPL for GOS
gos.SL=158.3000; % SPL for JH

% estimated recieve levels in pen (see methods document)
colpen.jh_rl=138  % antipated RL in pen during playback (see methods document)
colpen.gos_rl=125 % anticipated RL in pen during playback (see methods document)



range=1:200; % vector of ranges
jh.rl=jh.SL-20*log10(range);
gos.rl=gos.SL-20*log10(range);

% find where RL matches the level in the pen
index_gos=min(find(gos.rl<colpen.gos_rl));
index_jh=min(find(jh.rl<colpen.jh_rl));

figure
plot(range,jh.rl)
hold
plot(range,gos.rl,'r')
xlabel('Range to vessel')
ylabel('SPL dB re 1 uPa')
 
plot(range(index_jh),jh.rl(index_jh),'s');
plot(range(index_gos),gos.rl(index_gos),'sr');
legend('JH','GOS','JH playback','GOS playback')
