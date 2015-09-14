% Get pivs from folder

function getPIVsFromFolder(folder, denoising_method, denoising_param, denoising_label)
%  denoising_method:
%   -1: Use raw input image
%    0: Apply background subtraction and image normalization
%    1 - 12: apply gb sub and image normalization + denoising (check
%    preprocessingSonarImage.m for information about the different options

% Data will be saved following this scheme:
% ./PIVdata2/denoising_label/avi_file_name.mat

d=dir([folder '*.avi']);

for i=1:length(d)
    filedir{i} = folder;
    file{i} = d(i).name;
end

% Datafolder
datafolder = [filedir{1} 'PIVdata2'];
if ~(exist(datafolder,'dir')==7)
    disp(['Creating data folder, ' datafolder]);
    mkdir(datafolder);
end

for i = 1:length(d)
    disp(['Processing file ' int2str(i) '/' int2str(length(d))]);
    disp(denoising_label);
    filepath = [filedir{i}  file{i}];
    % Datapath
    datapath = [folder 'PIVdata2/' denoising_label{1} '/'];
    if ~(exist(datapath,'dir')==7)
        disp(['Creating data folder, ' datapath]);
        mkdir(datapath);
    end
    datapath   = strrep([datapath file{i}],'.avi','_PIV.mat');
    disp(['Get pivs for file ' filepath]);
    % Load Bg image
    bgpath = [filedir{i} 'PIVdata2/' file{i}];
    bgpath = strrep(bgpath, '.avi','_BG.bmp');
    BG = imread(bgpath);
    
    % Opening movie object
    disp(['..Opening ' filepath]);
    movieobj = VideoReader(filepath);
    
    I2  = read(movieobj, 1);
    [Irows Icolumns n] = size(I2);
    if(n>1)
        I2   = rgb2gray(I2);
    end
    
    if(denoising_method == 0)
        I2   = abs(I2-BG);
        I2   = normalizeSonarImage(I2);
    elseif(denoising_method >0)
        preprocessingSonarImage(); % Initialize
        I2 = preprocessingSonarImage(I2,BG,denoising_method,denoising_param,0,0);
    end
    n    = movieobj.NumberOfFrames-1;
    % The number of rows and columns is hardcoded in file DoFlow.m
    rows = 100;
    cols = 100;
    us   = zeros(rows,cols,n);
    vs   = zeros(rows,cols,n);
    xs   = zeros(rows,cols,n);
    ys   = zeros(rows,cols,n);
    
    
    xxs = 1:Icolumns;
    yys = 1:Irows;
    xxs = repmat(xxs,Irows,1);
    yys = repmat(yys,Icolumns,1);
    yys = yys';
    
    xxs = imresizeNN(xxs, [rows cols]);
    yys = imresizeNN(yys, [rows cols]);
    
    grad2Dm(I2,1,1); %initialize
    tic
    for j = 1:n
        I1 = I2;
        I2 = read(movieobj,j);
        [Irows Icolumns n] = size(I2);
        if(n>1)
            I2   = rgb2gray(I2);
        end
        
        if(denoising_method == 0)
            
            I2 = abs(I2-BG);
            I2 = normalizeSonarImage(I2);
        elseif(denoising_method >0)
            
            I2 = preprocessingSonarImage(I2,BG,denoising_method,denoising_param,0,0);
        end
        [dx dy dt] = grad2Dm(I2,I1);
        [us(:,:,j) vs(:,:,j)] = DoFlow(dx,dy,dt,'flow1');
        xs(:,:,j) = xxs(:,:);
        ys(:,:,j) = yys(:,:);
        
    end
    toc
    

    
    disp(['... Writing mat file with Raw PIV vectors: ' datapath]);
    save(datapath, 'xs', 'ys', 'us','vs');
    disp('Data saved');
    
end
end
