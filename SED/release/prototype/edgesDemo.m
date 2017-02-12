% Demo for Structured Edge Detector (please see readme.txt first).

%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms

%% evaluate edge detector on BSDS500 (see edgesEval.m)
if(0), edgesEval( model, 'show',1, 'name','' ); end

%% detect edge and visualize results
%{
I = imread('peppers.png');
tic, E=edgesDetect(I,model); toc
figure(1); im(I); figure(2); im(1-E);
%}
%% creating the slides of CT scan.

tic;
workingDir = 'prototype\slides';
createCTslides('10000019_1_CT_wb.nii.gz' , workingDir);
toc

%% evaluate SED forest algoritem on the slides
 
tic;
workingDir = 'prototype\slides';
imageNames = dir(fullfile(workingDir,'*.jpg'));
imageNames = {imageNames.name}';
a = size(imageNames);
length = a(1);

for i=1:length
    I = imread(fullfile(workingDir,imageNames{i}));
    I = cat(3, I, I, I);
    E=edgesDetect(I,model);
    filename = [sprintf('%03d',i) '.jpg'];
    fullname = fullfile(workingDir,'results\SED', filename);
    imwrite(1-E ,fullname);  
end
toc
%% output a video file.

tic;
videoName = 'SED.avi';
workingDir = 'prototype\slides\results\SED';
createVideo(workingDir , videoName);
toc