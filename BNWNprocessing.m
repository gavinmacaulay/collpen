%cd C:\repositories\CollPen_mercurial\BNWNpaper\
clear
clc
load('merged_match_PIVdata')
E=double(E);

% 1--predmodel2013_TREAT_Brown net_didson_block45_sub1.avi
% 2--predmodel2013_TREAT_Brown net_didson_block46_sub1.avi
% 3--predmodel2013_TREAT_Brown net_didson_block47_sub1.avi
% 4--predmodel2013_TREAT_Brown net_didson_block48_sub1.avi
% 5--predmodel2013_TREAT_Brown net_didson_block49_sub1.avi
% 6--predmodel2013_TREAT_Brown net_didson_block50_sub1.avi
% 7--predmodel2013_TREAT_Brown net_didson_block52_sub1.avi
% 8--predmodel2013_TREAT_Brown net_didson_block61_sub1.avi
% 9--predmodel2013_TREAT_Brown net_didson_block62_sub1.avi
% 10--predmodel2013_TREAT_Brown net_didson_block63_sub1.avi
% 11--predmodel2013_TREAT_Brown net_didson_block65_sub1.avi
% 12--predmodel2013_TREAT_Brown net_didson_block66_sub1.avi
% 13--predmodel2013_TREAT_Brown net_didson_block67_sub1.avi
% 14--predmodel2013_TREAT_Brown net_didson_block68_sub1.avi

% 15--predmodel2013_TREAT_White net_didson_block37_sub1.avi
% 16--predmodel2013_TREAT_White net_didson_block38_sub1.avi
% 17--predmodel2013_TREAT_White net_didson_block39_sub1.avi
% 18--predmodel2013_TREAT_White net_didson_block41_sub1.avi
% 19--predmodel2013_TREAT_White net_didson_block42_sub1.avi
% 20--predmodel2013_TREAT_White net_didson_block53_sub1.avi
% 21--predmodel2013_TREAT_White net_didson_block54_sub1.avi
% 22--predmodel2013_TREAT_White net_didson_block55_sub1.avi
% 23--predmodel2013_TREAT_White net_didson_block56_sub1.avi
% 24--predmodel2013_TREAT_White net_didson_block57_sub1.avi
% 25--predmodel2013_TREAT_White net_didson_block58_sub1.avi
% 26--predmodel2013_TREAT_White net_didson_block59_sub1.avi

% Relate frame number to block
file_block=[1 45;... % Brown
2 46;...
3 47;...
4 48;...
5 49;...
6 50;...
7 52;...
8 61;...
9 62;...
10 63;...
11 65;...
12 66;...
13 67;...
14 68;...
15 37;... % White
16 38;...
17 39;...
18 41;...
19 42;...
20 53;...
21 54;...
22 55;...
23 56;...
24 57;...
25 58;...
26 59];

% Label the predator exrtap/interp positions
frame_pixel = [];
f=dir('./predator_position/*interp_extrap_path.mat');
for i= 1:length(f) 
    %predmodel2013_TREAT_Brown net_didson_block45_sub1_interp_extrap_path
    fil = fullfile('./predator_position',f(i).name);
    bn=str2double(f(i).name(43:44));
    N=load(fil);
    %                         block no + pixel + info(frame ,x , y, extrap?
    frame_pixel = [frame_pixel;[repmat(bn,[size(N.frame_pixel_info,1) 1]),N.frame_pixel_info]];
end

%%

ind_file = unique(E(:,1));
for i = 1: size(ind_file,1)
    file_info = E(:,1) ==i;
    F = E(file_info,:);
    ind_frame = unique(F(:,2));
    
    file_info2 = frame_pixel(:,1)==file_block(i,2);
    G = frame_pixel(file_info2,:);
    ind_frame2 = unique(G(:,2));
    ind_frame2 = ind_frame2(1:end-1);
    equal_frames = ind_frame == ind_frame2;
    equal_frames = 1 - equal_frames;
    n_zeros = find(equal_frames);
    disp(['Video ' int2str(file_block(i,2))]);
    if n_zeros >= 1
    disp('Discrepancy');
    frames = [ ind_frame(equal_frames) ind_frame2(equal_frames) ];
    else
        disp('No discrepancy');
    end
   
end
keyboard

%% Get predator positions
F = cell(size(E,1),3);
F1 = double([size(E,1) 2]);

headerF = {'intpred','treatment'}
for i=1:size(E,1)
    % Look up block
    block = interp1(file_block(:,1),file_block(:,2),E(i,1),'nearest');% Block via file no
    ind = block==frame_pixel(:,1);% 
    F{i,1} = interp1(frame_pixel(ind,2),frame_pixel(ind,5),E(i,2),'nearest');
    if isnan(F{i,1})
       disp(i)
       break
    end
    F1(i,1)=F{i,1};
    if E(i,1)<15
        F{i,2}='Brown';
        F{i,3}=0;
        F1(i,2)=0;
    else
        F{i,2}='White';
        F{i,3}=1;
        F1(i,2)=1;
    end
end

%%
header = {'video_index','frame','pred_x','pred_y','pred_u','pred_v',...
'piv_x','piv_y','piv_u','piv_v','intensity_wsize',...
'intensity_half_wsize','score','fov_limit','block','Treat','TreatNo'};

% Interpolated predator?
intpred = F1(:,1);

% Treatment
treatment = F1(:,2)==1;

% Predator velocity data
vpxy = [E(:,5) E(:,6)];
[vpth,vpr] = cart2pol(vpxy(:,1),vpxy(:,2));
evp = vpxy./repmat(vpr,[1 2]);

% Prey velocity data
vxy = [E(:,9) E(:,10)];
[vth,vr] = cart2pol(vxy(:,1),vxy(:,2));
ev = vxy./repmat(vr,[1 2]);

% Vector from predator to prey
x = [E(:,7)-E(:,3) E(:,8)-E(:,4)];
% From predator to prey
[th,r] = cart2pol(x(:,1),x(:,2));
% Unity vector from predator to prey
e = x./repmat(r,[1 2]);

% Direction of prey relative to predator heading
TH = th-vpth;

% The dot product by range and framenumber
Fs = dot(e,vxy,2);
Fe = dot(e,ev,2);

% Create range label
f =0:50:450;
rc = NaN(size(r)); 
for j=1:length(f)-1
   indx =  r>f(j) & r<f(j+1);
   rc(indx)=j;
end

% Intensities
I = E(:,12);
frame = E(:,2);

%% Data filtering

% Restrict angles
ind1 = TH<pi/4 & TH>-pi/4;
% Kick out low score and border lines
ind2 = E(:,13)>0.15 & E(:,14)==0;
% Remove extrapolated predators
ind3 = intpred==2;

ind= ind1&ind2&ind3;

indB = treatment&ind;
indW = treatment&ind;

%% save data for R

% header = {'video_index','frame','pred_x','pred_y','pred_u','pred_v',...
% 'piv_x','piv_y','piv_u','piv_v','intensity_wsize',...
% 'intensity_half_wsize','score','fov_limit','block','Treat','TreatNo',...
% };

header2 = {'r','Fs','Fe','I','treat','th','score','file','frame'};
dat = [header2;[num2cell([r(ind) Fs(ind) Fe(ind) I(ind)]) F(ind,2) num2cell([TH(ind) E(ind,13) E(ind,1:2)])]];

%xlswrite('merged_match_PIVdata.xlsx',[header;[num2cell(E) F]])
cell2csv('merged_match_PIVdata.csv',dat)

%% Plotting

close all

figure(1)
hist(r,100)
xlabel('Range (px)')
ylabel('Number of data points')

figure(2)
boxplot(E(ind,12),[rc(ind) indW(ind)])
xlabel('Bins in range of 50 pixels steps, 0-50,50-100... px etc & White==1, Brown==0')
ylabel(header{12},'interp','none')

figure(3)
plot(r(ind), E(ind,11),'*')
xlabel('range(m)')
ylabel(header{11},'interp','none')

figure(4)
hist([vth(ind) vpth(ind)]*180/pi,100)
xlabel('degrees')
ylabel('Number of data points')
legend({'\theta prey ','\theta pred '})

figure(5)
subplot(211)
plot(r(ind), Fe(ind),'b*')
subplot(212)
plot(r(ind), Fs(ind),'b*')

figure(6)
boxplot(Fe(ind),[rc(ind) indW(ind)])
xlabel('Bins in range of 50 pixels steps, 0-50,50-100... px etc & White==1, Brown==0')
ylabel('Direction away from pred')

figure(7)
boxplot(Fs(ind),[rc(ind) indW(ind)])
xlabel('Bins in range of 50 pixels steps, 0-50,50-100... px etc & White==1, Brown==0')
ylabel('Speed away from pred')
plot(mean(vpr(:)))

figure(8)
plot3(Fe,r,frame,'*')
xlabel('range')
ylabel('framenumber')

%%
xnodes =0:50:800 ;
ynodes =0:5:75;

[zg,xg,yg] = gridfit(r,frame,Fe,xnodes,ynodes);

figure(9)
clf
surf(xg,yg,zg)
shading interp
% hold on 
% plot3(r,frame,Fs,'*')
colormap(jet(256))
camlight right
lighting phong
view(2)
colorbar

xlabel('r')
ylabel('frame')
zlabel('Fe')



