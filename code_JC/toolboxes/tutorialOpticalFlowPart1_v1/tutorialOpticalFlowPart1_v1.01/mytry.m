close all
clear


d=dir('/Volumes/Datos/collpen/predator/*.avi');

for i=1:length(d)
    filedir{i} = '/Volumes/Datos/collpen/predator/';
    file{i} = d(i).name;
end

% Datafolder
datafolder = [filedir{1} 'PIVdata2'];
if ~(exist(datafolder,'dir')==7)
    disp(['Creating data folder, ' datafolder]);
    mkdir(datafolder);
end

   denoising_method = 12;
   denoising_param = 100;

for i = 1:length(d)
     
    filepath = [filedir{i}  file{i}];
    % Datapath
    datapath   = strrep([filedir{i} 'PIVdata2/' file{i}],'.avi','_PIV.mat');
    disp(['Get pivs for file ' filepath]);
    % Load Bg image
    bgpath = [filedir{i} 'PIVdata2/' file{i}];
    bgpath = strrep(bgpath, '.avi','_BG.bmp');
    BG = imread(bgpath);
    
    % Opening movie object
    disp(['..Opening ' filepath]);
    movieobj = VideoReader(filepath);
    
    RGB  = read(movieobj, 1);
    I2   = rgb2gray(RGB);
%     I2   = abs(I2-BG);
%     I2   = normalizeSonarImage(I2);
    I2 = preprocessingSonarImage(I2,BG,denoising_method,denoising_param,0,0);

    n    = movieobj.NumberOfFrames-1;
    % The number of rows and columns is hardcoded in file DoFlow.m
    rows = 100; 
    cols = 100;
    us   = zeros(rows,cols,n);
    vs   = zeros(rows,cols,n);
    
   
    grad2Dm(I2,1,1); %initialize
    tic
    for j = 1:n
        I1 = I2;
        I2 = rgb2gray(read(movieobj,j));
%         I2 = abs(I2-BG);
%         I2 = normalizeSonarImage(I2);
        I2 = preprocessingSonarImage(I2,BG,denoising_method,denoising_param,0,0);

        [dx dy dt] = grad2Dm(I2,I1);
        [us(:,:,j) vs(:,:,j)] = DoFlow(dx,dy,dt,'flow1');
        
    end
    toc
    disp(['... Writing mat file with Raw PIV vectors: ' datapath]);
    save(datapath, 'us','vs');
    disp('Data saved');
    
end


%% Script to generate a video

close all
clear


d=dir('/Volumes/Datos/collpen/predator/*.avi');

for i=1:length(d)
    filedir{i} = '/Volumes/Datos/collpen/predator/';
    file{i} = d(i).name;
end

% Datafolder
datafolder = [filedir{1} 'PIVdata2'];


f = figure;

for i = 1:length(d)
     
    filepath = [filedir{i}  file{i}];
    % Datapath
    datapath   = strrep([filedir{i} 'PIVdata2/' file{i}],'.avi','_PIV.mat');
    pivavipath = strrep(datapath, 'mat','avi');
    disp(['Generate PIV video for file ' filepath]);
    load(datapath);
    
     % Opening movie object
    disp(['..Opening ' filepath]);
    movieobj = VideoReader(filepath);
    
    n    = movieobj.NumberOfFrames-1;
    %aviobj = avifile(pivavipath, 'compression', 'none', 'fps',8);
    aviobj = VideoWriter(pivavipath);
    aviobj.FrameRate = movieobj.FrameRate;
    open(aviobj);

    % Loop to generate avi file
    disp(['Creating PIV avi in ' pivavipath]);
    tic
    for j = 1: n
            I   = rgb2gray(read(movieobj, j));
            colormap gray
            [r c] = size(I);
            subplot(1,2,1);
            imagesc(I); axis equal;axis tight;
            subplot(1,2,2); 
            imagesc(I); axis equal;axis tight;
            hold on
            %US = imresizeNN(us(:,:,j),size(I));
            %VS = imresizeNN(vs(:,:,j),size(I));
            US = us(:,:,j);
            VS = vs(:,:,j);
            US = medfilt2(US); % Median filter
            VS = medfilt2(VS); % Median filter
            uindex = find(US);
            ux = floor(uindex/100)+1;
            uy = mod(uindex,100);
            USi = US(uindex);
            VSi = VS(uindex);
            quiver(ux*c/100, uy*r/100, USi, VSi, 2,'r');

            hold off
            pause(0.125);
            F = getframe(f);
           % aviobj = addframe(aviobj,F.cdata);
            writeVideo(aviobj,F.cdata);

    end
    toc
    close(aviobj); 
    disp('Video created');
end


%%

I = imread('/Volumes/Datos/collpen/collpen/imgs_test/sonar1.png');
I = rgb2gray(I);

grad2Dm(I,1,1);

I2 = imread('/Volumes/Datos/collpen/collpen/imgs_test/sonar2.png');
I2 = rgb2gray(I2);



[dx dy dt] = grad2Dm(I2,1);
[U1, V1] = DoFlow(dx,dy,dt,'flow1');

U2 = imresizeNN(U1,size(I2));
V2 = imresizeNN(V1,size(I2));

    
[r c] = find(U2);

UU = U2(c);
VV = V2(r);
imagesc(I2); axis equal; axis tight;
hold on;
quiver( UU,VV, 'g');
