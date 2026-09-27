clc;
clear;
close all;

%% Project paths

projectRoot = 'D:\SIH26038_DR_Project';

modelPath = fullfile( ...
    projectRoot, ...
    'models', ...
    'resnet18_dr_trained.mat');

imageFolder = fullfile( ...
    projectRoot, ...
    'data', ...
    'APTOS', ...
    'train_images');

addpath(fullfile(projectRoot, 'app', 'functions'));

%% Check model file

if ~exist(modelPath, 'file')
    error('Trained model was not found at: %s', modelPath);
end

%% Load trained model

loadedData = load(modelPath);

variableNames = fieldnames(loadedData);

disp('Variables found in model file:');
disp(variableNames);

% Automatically identify the trained network
trainedNet = [];

for i = 1:numel(variableNames)

    candidate = loadedData.(variableNames{i});

    if isa(candidate, 'SeriesNetwork') || ...
            isa(candidate, 'DAGNetwork') || ...
            isa(candidate, 'dlnetwork')

        trainedNet = candidate;
        break;
    end
end

if isempty(trainedNet)
    error(['No supported trained network was found in the MAT file. ', ...
        'Check the variable stored in the model file.']);
end

disp('Trained model loaded successfully.');

%% Select fundus image

[fileName, filePath] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg', 'Fundus Images'}, ...
    'Select a Fundus Image', ...
    imageFolder);

if isequal(fileName, 0)
    disp('No image selected.');
    return;
end

imagePath = fullfile(filePath, fileName);
originalImage = imread(imagePath);

%% Convert grayscale image to RGB

if ndims(originalImage) == 2
    originalImage = repmat(originalImage, [1 1 3]);
end

%% Get model input size

inputSize = trainedNet.Layers(1).InputSize;

if numel(inputSize) >= 2
    imageHeight = inputSize(1);
    imageWidth = inputSize(2);
else
    imageHeight = 224;
    imageWidth = 224;
end

%% Prepare image for the model

modelImage = imresize(originalImage, ...
    [imageHeight imageWidth]);

% Ensure the image has three channels
if size(modelImage, 3) == 1
    modelImage = repmat(modelImage, [1 1 3]);
end

%% Run prediction

[predictedLabel, scores] = classify(trainedNet, modelImage);

confidence = max(scores) * 100;

%% Display image and prediction

figure( ...
    'Name', 'NAYANTRA - AI Screening Result', ...
    'NumberTitle', 'off', ...
    'Color', 'w');

imshow(originalImage);

titleText = sprintf( ...
    'Predicted Grade: %s | Confidence: %.2f%%', ...
    char(predictedLabel), ...
    confidence);

title(titleText, ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

%% Display report in Command Window

fprintf('\n============================================\n');
fprintf('          NAYANTRA AI SCREENING RESULT\n');
fprintf('============================================\n');

fprintf('Image Name       : %s\n', fileName);
fprintf('Predicted Grade  : %s\n', char(predictedLabel));
fprintf('Confidence       : %.2f%%\n', confidence);

fprintf('\nGrade Probabilities:\n');

for i = 1:numel(scores)

    fprintf('Grade %d           : %.2f%%\n', ...
        i - 1, ...
        scores(i) * 100);

end

fprintf('\nInterpretation:\n');

switch char(predictedLabel)

    case '0'
        fprintf('No diabetic-retinopathy signs predicted by the model.\n');

    case '1'
        fprintf('Mild diabetic-retinopathy signs predicted by the model.\n');

    case '2'
        fprintf('Moderate diabetic-retinopathy signs predicted by the model.\n');

    case '3'
        fprintf('Severe diabetic-retinopathy signs predicted by the model.\n');

    case '4'
        fprintf('Proliferative diabetic-retinopathy signs predicted by the model.\n');

    otherwise
        fprintf('The model returned an unexpected class label.\n');

end

fprintf('\nNote: This is an educational research prototype, not a clinical diagnosis.\n');
fprintf('============================================\n');