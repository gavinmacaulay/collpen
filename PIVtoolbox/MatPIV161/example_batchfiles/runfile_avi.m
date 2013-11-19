%%%%%%%%%%%%%%%%%%%%% Settings
T=0.04;       % Time separation between base and cross images.
met='multin'; % Use interrogation window offset
wins=[64 64;64 64;32 32;32 32]; %windowsizes to use in the iterations
woco='worldco1.mat'; % World coordinate file. This may be changed
                     % within the loop as well, e.g. in the cases 
                     % where there are two cameras
snrtrld=1.2;  % threshold for use with snr-filtering
globtrld=3;   % threshold for use with globalfiltering
loctrld=1.7;  % threshold for use with local filtering
med='median'; % Use median filtering in localfilt
int='linear'; % interpolate outliers using linear interpolation
maskfile='polymask.mat'; % name of file containing the pre-defined mask
A=aviread('myfile.avi'));  % load the movie. If the movie is large
                           % this should be done inside the loop
%%%%%%%%%%%%%%%%%%%%
for i=1:length(A)-1
  % PIV calculation
  [x,y,u,v,snr]=matpiv(A(i).cdata,A(i+1).cdata,wins,T,0.5,met,woco,maskfile);'])
  % SnR filter:
  [su,sv]=snrfilt(x,y,u,v,snr,snrtrld);
  % global filter:
  [gu,gv]=globfilt(x,y,su,sv,globtrld);
  % local median filter:
  [lu,lv]=localfilt(gu,gv,loctrld,med,x,y);'])
  % interpolate outliers
  [fu,fv]=naninterp(lu,lv,int,maskfile,x,y);'])

  save(['vel_field',num2str(i),'.mat'],'u','v','snr','fu','fv');

  if i==1
     save coordinates.mat x y
  end

end.