function [datapath rawpivel] = PIV_getRawPIVvectors(folder, avifilename, parstr)
    
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]: Start');
    
    % Initiation
    datapath = [];rawpivel=[];
    if nargin==2
        [folder, avifilename, parstr] = checkingArguments(folder, avifilename);
    elseif nargin==3
        [folder, avifilename,parstr] = checkingArguments(folder, avifilename,parstr);
    else
        [folder, avifilename, parstr] = checkingArguments();
        dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]: End');
        return;
    end
    
    % Datafolder
    datafolder = [folder '\PIVdata'];
    if ~(exist(datafolder,'dir')==7)
        dispMsg(parstr.showmsg,['[PIV_getRawPIVvectors]: Creating data folder, ' datafolder]);
        mkdir(datafolder);
    end
    
    
    % Datapath
    datapath   = strrep([datafolder '\' avifilename],'.avi','_PIV.mat');
    
    % Empty answer
    rawpivel    = struct('parstr',parstr,'xs',[],'ys',[],'us',[],'vs',[],'snrs',[],'pkhs',[],'is',[]);
    
    %Do not repeat if analysis already done
    currentparstr = parstr;
    if exist(datapath, 'file') == 2
        load(datapath);
        pos = -1;
        for i=1:length(pivdatas)
            parstr = pivdatas(i).rawpivel.parstr;
            if compareStruct(currentparstr,parstr)
                pos      = i;
                if currentparstr.useold
                    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]: ..Using previously created PIVs');
                    rawpivel = pivdatas(pos).rawpivel;
                    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]: End');
                    return;
                end
            end
        end
        if pos<1
            pos = length(pivdatas)+1;
        end
    else
        pivdata=struct('rawpivel',rawpivel);
        pivdatas = repmat(pivdata, 1,1);
        pos = 1;
    end
    parstr = currentparstr;
   
    % Getting raw vectors/datas
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]:....');
    [rawpivel.xs rawpivel.ys rawpivel.us rawpivel.vs rawpivel.snrs rawpivel.pkhs rawpivel.is] = ...
        PIV_getSubRawPIVvectors(folder, avifilename, parstr);
    pivdatas(pos).rawpivel=rawpivel;
    
    % writing mat file with vectors
    if parstr.write
        dispMsg(parstr.showmsg,['[[PIV_getRawPIVvectors]: ..Writing mat file with Raw PIV vectors: ' datapath]);
        save(datapath,'pivdatas');
    end
    dispMsg(parstr.showmsg,'[PIV_getRawPIVvectors]: End');

end

function [xs ys us vs snrs pkhs is] = PIV_getSubRawPIVvectors(folder, avifilename, parstr)
% dx     : 1 or 0
% dy     : 1 or 0
% winsize: 32 64 128

    
    
    %% Initiating
    
    %addpath('MatPIV161');
    %filepath='DidsonFilesOfInterest\didson_block22_sub1_treat1.avi';
    filepath=[folder '/' avifilename];
    
    %% Opening movie object
    disp(['[PIV_getRawPIVvectors]:..Opening ' filepath]);
%    info     = aviinfo(filepath);
%    movieobj = mmreader(filepath);
movieobj = VideoReader(filepath);
    %% PIV settings 
    winsize = parstr.winsize;
    olap    = parstr.olap;
    param   = 'single'; %multi/single 
    dt      = 1;
    rows    = 1;
    cols    = 1;

    % initiating
    try
        RGB2                        = read(movieobj, 1);
        I2                          = rgb2gray(RGB2);
        I1                          = I2;
        [T,xs,ys,us,vs,snrs,pkhs]   = evalc('matpivCP(I1,I2,winsize,dt,olap,param)');
        [rows cols]                 = size(xs);
    catch exception
        disp('[PIV_getRawPIVvectors]: ERROR!')
    end
  
    % PIV data vectors
    n      = movieobj.NumberOfFrames-1;
    xs     = zeros(rows,cols,n);
    ys     = zeros(rows,cols,n);
    us     = zeros(rows,cols,n);
    vs     = zeros(rows,cols,n);
    snrs   = zeros(rows,cols,n);
    pkhs   = zeros(rows,cols,n);
    is     = zeros(rows,cols,n);

    %% PIV - loop
    dispMsg(parstr.showmsg,['[PIV_getRawPIVvectors]:..Performing PIV-analysis of all frames']); c=0;
    RGB2    = read(movieobj, 1);
    I2      = RGB2(:,:,1);
    H       = fspecial('average', winsize);
    for i=1:1:n
        I1  = I2;
        warning off
        If  = imfilter(I1,H); % Lars: So that is is based on average in window, change done 14.11.2013
        warning on
        
        % Loading frames
        RGB2    = read(movieobj, i+1);
        I2=RGB2(:,:,1);
        
        % Outut to show that something is happening
        c=c+1;
        if c>30
            dispMsg(parstr.showmsg,['[PIV_getRawPIVvectors]:....Frame: ' num2str(i) ' of ' num2str(n) ' analysed']); c=0;
        end

        % PIV
        try
            [T,xs(:,:,i),ys(:,:,i),us(:,:,i),vs(:,:,i),snrs(:,:,i),pkhs(:,:,i)] = evalc('matpivCP(I1,I2,winsize,dt,olap,param)');
            tmpx=xs(1,:,i);
            tmpy=ys(:,1,i);
            is(:,:,i)=If(tmpy(:),tmpx(:));
        catch exception
            warning(['[PIV_getRawPIVvectors]: Error in matpiv for frames ' num2str(i) ' and ' num2str(i+1)]);
            disp(exception.message);
        end
    end
    

end

% Showing msgtxt if on
function dispMsg(on, msgtext) 
    if on
        disp(msgtext);
    end
end
   
% Checking that input arguments are correct
function [folder, avifilename,parstr]=checkingArguments(folder, avifilename,parstr)
    avifilename=strrep([avifilename '.avi'],'.avi.avi','.avi');
    dparstr = struct('showmsg',1,'winsize',64,'olap',0.5,'write',1,'useold',1,'medianfilter',0,'bgfilter',0);
    
    % Initiating arguments
    if nargin<2
        warning(1,'Too few input arguments: PIV_getRawPIVvectors(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr));
        return;
    elseif nargin==2
        parstr=dparstr;
    elseif nargin>3
        warning(2,'Too many input arguments:PIV_getRawPIVvectors(folder, avifilename, parstr), parstr:')
        disp(fieldnames(dparstr));
        return;
    else  % nargin==3 
        if sum(strcmp('showmsg',fieldnames(parstr)))==1
            dparstr.showmsg = parstr.showmsg;
        end
        if sum(strcmp('winsize',fieldnames(parstr)))==1
            dparstr.winsize = parstr.winsize;
        end
        if sum(strcmp('olap',fieldnames(parstr)))==1
            dparstr.olap = parstr.olap;
        end
        if sum(strcmp('write',fieldnames(parstr)))==1
            dparstr.write = parstr.write;
        end
        if sum(strcmp('useold',fieldnames(parstr)))==1
            dparstr.useold = parstr.useold;
        end
        if sum(strcmp('medianfilter',fieldnames(parstr)))==1
            dparstr.medianfilter = parstr.medianfilter;
        end
        if sum(strcmp('bgfilter',fieldnames(parstr)))==1
            dparstr.bgfilter = parstr.bgfilter;
        end
        parstr = dparstr;
    end
    
end

% Always run after checkingArguments-function
% Only compares paramater arguments that matter for the analysis
function answer = compareStruct(parstruct1,parstruct2) 
    if isequal(parstruct1,parstruct2)
        answer = 1;
    else
        answer = 1;
        if parstruct1.winsize ~= parstruct2.winsize
            answer = 0;
        elseif parstruct1.olap ~= parstruct2.olap
            answer = 0;
        end
    end  
end




function [xw,yw,uw,vw,SnR,Pkh,u2,v2]=matpivCP(varargin)
% MATPIV - the Particle Image Velocimetry toolbox for MATLAB
%
% function [xw,yw,uw,vw,snr,pkh]=matpiv(im1,im2,winsize,Dt,overlap...
% ,method,wocofile,mask,ustart,vstart)
%
% IM1 and IM2 are the images to perform PIV with.
% WINSIZE is the size of the interrogation windows, DT is the time
% between images, OVERLAP is the overlap of interrogation wins 
% (measured in percent), METHOD defines the method for calculating
% velocities (single pass='single', multiple passes='multi', 
% autocorrelation='auto' and phase correlation (single pass)= 'phase'. 
%
% Autocorrelation requires only one image and this should be 
% specified as IM1. In the place of the second image one should 
% specify the artificial window shift present, using square 
% brackets. If no window shift is available, specify [0 0],
%
% WINSIZE can be a N*2 vector containing the size of the interrogation regions 
% (x and y). F.eks inserting [64 64;64 64;32 32;32 32;16 16;16 16] will 
% cause MATPIV to use 6 passes starting with 64*64 windows and ending with 16*16.
% It is also possible to use something like [64 64;64 32;32 32;32 16;32 16]
% resulting in 5 passes ending up with 32*16 pixels large interrogation regions.
%
% WOCOFILE is a file as produced by the m-file DEFINEWOCO. The 
% latter file calculates the linear pixel to world mapping 
% coefficients (using the m-file TLS) and saves them to WOCOFILE
% (Typically called 'worldco1.mat'). WOCOFILE can be omitted 
% when calling MATPIV. The results will then be measured in
% pixels and pixels/cm.
% Please consult a decent book on PIV for a better explanation 
% and theoretical understanding of the subject.
%
% Latest addition is an extension of the MULTIPASS method and uses
% one more pass than the original version. It is called 'multin'.
%
% See also:
%            INTPEAK, DEFINEWOCO, PIXEL2WORLD, VALIDATE
%            SINGLEPASS, MULTIPASS, DESAMPLEPASS, HISTOOP
%            DIFFQUANT, INTQUANT, AUTOPASS

% MatPIV v. 1.6.1  Copyright J.K.Sveen (jks@math.uio.no),
%                  Department of Mathematics, Mechanics Division
%                  University of Oslo, Norway
%
% Distributed under the terms of the terms of the 
% GNU General Public License
%
% Time Stamp: 16:27, Jul 17, 2004
%
% Signal-To-Noise-Ratio calculation method by 
% Alex Liberzon and Roi Gurka.


addpath(genpath('MatPIV161')); % Lars

%%%%%%%%%%%%%%%% Declarations
               %
validvec=3;    % Threshold value for use with the 
               % Vector validation needed in multipass operation 
%%%%%%%%%%%%%%%%

    fprintf('\n');
    % asign the input paramteres in VARARGIN to the appropriate variables
    if length(varargin)==1
        fil=varargin{:}; fil=fil(1:end-2); eval(fil);
        if (ischar(msk)& ~isempty(msk)), mss=load(msk);ms=mss.maske; end
        if exist('ustart','var')==0, ustart=[]; vstart=[]; end
    end
    if nargin==5
      [im1,im2,winsize,Dt,overlap]=deal(varargin{:}); ms=''; ustart=[];vstart=[];
    elseif nargin==6
      [im1,im2,winsize,Dt,overlap,method]=deal(varargin{:}); ms='';
       ustart=[];vstart=[];
    elseif nargin==7
      [im1,im2,winsize,Dt,overlap,method,wocofile]=deal(varargin{:});
      ms=''; ustart=[];vstart=[]; 
    elseif nargin==8
      [im1,im2,winsize,Dt,overlap,method,wocofile,msk]=deal(varargin{:});
      if (ischar(msk) & ~isempty(msk)), mss=load(msk);ms=mss.maske; else, ms=msk; end
       ustart=[];vstart=[];
    elseif nargin==10
      [im1,im2,winsize,Dt,overlap,method,wocofile,msk,ustart,vstart]=deal(varargin{:});
      if ischar(msk), mss=load(msk);ms=mss.maske; end
    end

    if strcmp(method,'single')==1
      [x,y,u,v,SnR,Pkh,u2]=singlepassCP(im1,im2,winsize,Dt,overlap,ms);
    elseif strcmp(method,'norm')==1
      [x,y,u,v,SnR,Pkh,u2,v2]=normpass(im1,im2,winsize,Dt,overlap,ms);
    elseif ~isempty(findstr(method,'multi')) %~=0
        if size(winsize,1)>1
          if winsize(end,1)~=winsize(end-1,1)
        disp('Adding one iteration so that there are 2 iterations with')
        disp('the final interrogation window size')
        disp('   ')
        winsize=[winsize;winsize(end,:)];
          end
          iter=size(winsize,1);
        else
          iter=str2num(method(6:end));
        end

        if isempty(iter)
          iter=3;
        end

        if strcmp(method,'multin') | size(winsize,1)>1
          [x,y,u,v,SnR,Pkh]=multipassx(im1,im2,winsize,...
                       Dt,overlap,validvec,ms,iter, ...
                       ustart,vstart); 
        elseif strcmp(method,'multi') & size(winsize,1)==1
          [x,y,u,v,SnR,Pkh]=multipass(im1,im2,winsize,...
                       Dt,overlap,validvec,ms); 
        end

    elseif strcmp(method,'mqd')==1
        [x,y,u,v,SnR,Pkh]=mqd(im1,im2,winsize,Dt,overlap,ms); 
    elseif strcmp(method,'auto')==1
        if ischar(im2)==1
            disp(['Window shift should be a numeric vector',...
                    'in sqaure brackets, not a string!'])
            return
        else
            wshift=im2;
        end
        [x,y,u,v,SnR,Pkh]=autopass(im1,winsize,Dt,overlap,wshift,ms);
        A=imread(im1); mfigure,(1),clf,imshow(A,[],'truesize')
        axis on, hold on, mfigure(1) 
        quiver(x,y,u,v,2,'g'), title('Measurements in pixel coordinates'); axis ij  
    else
        disp('NOT A VALID CALCULATION METHOD!'); return
    end

    if nargin>6 | nargin==1
        if ~isempty(wocofile)
            % Transform from pixel coordinates to world coordinates.
            % You need to have a file called "worldco*.mat" as produced by the
            % DEFINEWOCO m-file in the present directory.
            % Change 'linear' to 'nonlinear' if you want nonlinear mapping.
            D=dir(wocofile);
            if size(D,1)==1
                mapp=load(D(1).name);
                [xw,yw,uw,vw]=pixel2world(u,v,x,y,mapp.comap(:,1),mapp.comap(:,2));
            else
                disp('No such world coordinate file present!')
                xw=x; yw=y;
                uw=u; vw=v;
                return
            end
            %save pixelcordinateresults.mat x y u v
        else
            %disp('No world coordinate file specified!')
            xw=x; yw=y;
            uw=u; vw=v; 
        end
    elseif (nargin<=7 & nargin>1) | isempty(wocofile)
        %disp('No coordinate mapping file specified.')
        %disp('Using pixel coordinates!')
        xw=x; yw=y;
        uw=u; vw=v;
    end

    if nargout==1
        xw.x=xw;  xw.y=yw;
        xw.u=uw;  xw.v=vw;
        xw.snr=SnR; xw.pkh=Pkh;
    end

end


function [x,y,u,v,SnR,Pkh,u2]=singlepassCP(im1,im2,winsize,Dt,overlap,maske)
%SINGLEPASS - Particle Image Velocimetry with fixed interrogation regions.
%
%function [x,y,u,v,snr,pkh]=singlepass2(im1,im2,winsize,Dt,overlap,mask)
%Provides PIV with a single pass through the images specified in IM1
%and IM2 with the interrogation window size WINSIZE. The interrogation
%windows are allowed to overlap by the amount specified in OVERLAP
%(meas. in percent). DT is the time between the images.  All results are
%measured in pixels or pixels/cm.  See also: MATPIV, INTPEAK,
%DEFINEWOCO, PIXEL2WORLD, MULTIPASS, DESAMPLEPASS, SNRFILT, GLOBFILT
%LOCALFILT


% Copyright 1998-2000, Kristian Sveen, jks@math.uio.no 
% for use with MatPIV 1.6.1
% Distributed under the terms of the Gnu General Public License
% Time stamp: 10:47, Jun 03 2004

% Image read
if ischar(im1)
    [A p1]=imread(im1);    [B p2]=imread(im2);
    if any([isrgb(A), isrgb(B)])
        A=rgb2gray(A); B=rgb2gray(B);
    end   
    if ~isempty(p1), A=ind2gray(A,p1); end
    if ~isempty(p2), B=ind2gray(B,p2); end
else
    A=im1; B=im2;
end   
[sta,ind]=dbstack; % to suppress output if called from MATPTV
A=double(A); B=double(B);
%A=double(imread(im1)); B=double(imread(im2));
% Various declarations
M=winsize; N=M; ci1=1; cj1=1;
x=zeros(ceil((size(A,1)-winsize)/((1-overlap)*winsize)), ...
    ceil((size(A,2)-winsize)/((1-overlap)*winsize)));
y=x; u=x; v=x; 
dumx=ones(size(A,1),1) * ([1:size(A,2)]);
dumy=([1:size(A,1)].') * ones(1,size(A,2));
if nargin==6, if ~isempty(maske)
        IN=zeros(size(maske(1).msk));
        for i=1:length(maske)
            IN=IN+double(maske(i).msk);
        end
    else IN=zeros(size(A)); end, end
% Create bias correction matrix
BiCor=xcorrf2(ones(winsize),ones(winsize))/(winsize*winsize);
% change 4. october 2001, weight matrix added.
W=weight('cosn',winsize,20); 
%t0=clock;
if size(sta,1)<=1  
  disp('* Single pass')
else
  if isempty(findstr(sta(end).name,'matptv')) 
    disp('* Single pass')
  end
end
SA=std(A(:));

tic
% MAIN LOOP
for jj=1:(1-overlap)*winsize:size(A,1)-winsize+1
    for ii=1:(1-overlap)*winsize:size(A,2)-winsize+1
        if IN(jj+N/2,ii+M/2)~=1
            C=A(jj:jj+winsize-1,ii:ii+winsize-1);
            D=B(jj:jj+winsize-1,ii:ii+winsize-1);
            % Calculate the standard deviation of each of the subwindows
            stad1=std(C(:));stad2=std(D(:));
            if stad1<0.2*SA, stad1=NaN; end
            if stad2<0.2*SA, stad2=NaN; end
            % Subtract the mean of each window to avoid correlation of
            % the mean background intensities.
            C=C-mean(C(:));
            D=D-mean(D(:)); 
            % uncomment below to use weighting
            C=C.*W; D=D.*W;

            % Calculate the correlation using the xcorrf2 (found at the 
            % Mathworks web site). Divide by N (winsize) and the stad's 
            % to normalize the peakheights.
            if isnan(stad1)~=1 & isnan(stad2)~=1
                R=xcorrf2(C,D)./(winsize*winsize*stad1*stad2);
                % Correct for displacement bias
                R=R./BiCor;    
                % Locate the highest point   
                [y1,x1]=find(R==max(max(R(0.5*winsize+2:1.5*winsize-3,...
                    0.5*winsize+2:1.5*winsize-3))));
                if size(x1,1)>1 | size(y1,1)>1 
		  x1=round(sum(x1.*([1:length(x1)]'))./sum(x1));
		  y1=round(sum(y1.*([1:length(y1)]'))./sum(y1));
                end
                try 
                    % Interpolate to find the peak position at subpixel resolution,
                    % using three point curve fit function INTPEAK.
                    % X0,Y0 now denotes the displacements.
                    % Nils Olav: We added ones to the aRses to avoid problem
                    % when the data is noisy. We also changed this to method
                    % 1 to be less vulnerable to noise.
                    [x0,y0]=intpeak(x1,y1,R(y1,x1)+1,R(y1,x1-1)+1,R(y1,x1+1)+1,...                  
                                          R(y1-1,x1)+1,R(y1+1,x1)+1,1,winsize);
                    R2=R;
                    R2(y1-3:y1+3,x1-3:x1+3)=NaN;
                    [p2_y2,p2_x2]=find(R2==max(max(R2( 0.5*N+2:1.5*N-3,0.5*M+2:1.5*M-3))));
                    if length(p2_x2)>1
                        p2_x2=p2_x2(round(length(p2_x2)/2)); 
                        p2_y2=p2_y2(round(length(p2_y2)/2)); 
                    end
                    % Store the data
                    x(cj1,ci1)=(winsize/2)+ii-1;
                    y(cj1,ci1)=(winsize/2)+jj-1;
                    u(cj1,ci1)=-x0/Dt;
                    v(cj1,ci1)=-y0/Dt;
                    SnR(cj1,ci1)=R(y1,x1)/R2(p2_y2,p2_x2);
                    Pkh(cj1,ci1)=R(y1,x1);
                    u2(cj1,ci1)=sum(R(:));
                catch exception
                    x(cj1,ci1)=(winsize/2)+ii-1; %Lars
                    y(cj1,ci1)=(winsize/2)+jj-1;
                    u(cj1,ci1)=NaN;
                    v(cj1,ci1)=NaN;
                    SnR(cj1,ci1)=NaN;
                    Pkh(cj1,ci1)=NaN;
                    u2(cj1,ci1)=NaN;
                    disp(exception.message);
                end
            else
                u(cj1,ci1)=NaN; v(cj1,ci1)=NaN; SnR(cj1,ci1)=NaN; Pkh(cj1,ci1)=NaN; u2(cj1,ci1)=nan;
                x(cj1,ci1)=(ii+(winsize/2)-1);
                y(cj1,ci1)=(jj+(winsize/2)-1);
            end
            % Update counters
            ci1=ci1+1;
        else
            x(cj1,ci1)=(winsize/2)+ii-1;
            y(cj1,ci1)=(winsize/2)+jj-1;
            u(cj1,ci1)=NaN;
            v(cj1,ci1)=NaN;
            SnR(cj1,ci1)=NaN;
            Pkh(cj1,ci1)=NaN;  u2(cj1,ci1)=nan;
	    ci1=ci1+1;
        end  

    end
    % Display calculation time
    if size(sta,1)<=1   
      fprintf('\r No. of vectors: %d', (cj1-1)*(ci1)+ci1-1 -sum(isnan(u(:))))
      fprintf(' , Seconds taken: %f', toc); %etime(clock,t0));
    else
      if isempty(findstr(sta(end).name,'matptv'))   
	fprintf('\r No. of vectors: %d', (cj1-1)*(ci1)+ci1-1 -sum(isnan(u(:))))
	fprintf(' , Seconds taken: %f', toc); %etime(clock,t0));
      end
    end  
    
    ci1=1;
    cj1=cj1+1;
end

if size(sta,1)<=1  
  fprintf('.\n');
else
  if isempty(findstr(sta(end).name,'matptv')) 
      fprintf('.\n');
  end
end

end

% now we inline the function XCORRF2 to shave off some time.

function c = xcorrf2(a,b)
%  c = xcorrf2(a,b)
%   Two-dimensional cross-correlation using Fourier transforms.
%       XCORRF2(A,B) computes the crosscorrelation of matrices A and B.
%       XCORRF2(A) is the autocorrelation function.
%       This routine is functionally equivalent to xcorr2 but usually faster.
%       See also XCORR2.

%       Author(s): R. Johnson
%       $Revision: 1.0 $  $Date: 1995/11/27 $

[ma,na] = size(a);
% if nargin == 1
%     %       for autocorrelation
%     b = a;
% end
[mb,nb] = size(b);
%       make reverse conjugate of one array
b = conj(b(mb:-1:1,nb:-1:1));

%       use power of 2 transform lengths
mf = 2^nextpow2(ma+mb);
nf = 2^nextpow2(na+nb);
at = fft2(b,mf,nf);
bt = fft2(a,mf,nf);
%       multiply transforms then inverse transform
c = ifft2(at.*bt);
%       make real output for real input
if ~any(any(imag(a))) & ~any(any(imag(b)))
    c = real(c);
end
%  trim to standard size
c(ma+mb:mf,:) = [];
c(:,na+nb:nf) = [];
end


