function screening = runNayantraScreening()
%% runNayantraScreening
% NAYANTRA - Integrated Diabetic Retinopathy Screening
%
% Pipeline:
% Image Selection
%       ->
% Fundus Validation
%       ->
% Image Quality Check
%       ->
% Resize / Color Handling
%       ->
% ResNet-18 Prediction
%
% NOTE:
% Research / hackathon prototype.
% Not a clinically validated diagnostic system.

clc;
close all;

%% ============================================================
% 1. PROJECT PATHS
% =============================================================

projectRoot = 'D:\SIH26038_DR_Project';

functionsFolder = fullfile( ...
    projectRoot, 'app', 'functions');

imageFolder = fullfile( ...
    projectRoot, ...
    'data', ...
    'APTOS', ...
    'train_images');

modelPath = fullfile( ...
    projectRoot, ...
    'models', ...
    'resnet18_dr_trained.mat');

addpath(functionsFolder);

%% ============================================================
% 2. CHECK MODEL
% =============================================================

if ~isfile(modelPath)

    error(['Model not found:' newline modelPath]);

end

%% ============================================================
% 3. SELECT IMAGE
% =============================================================

[fileName, filePath] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg;*.bmp', ...
    'Fundus Image Files'}, ...
    'NAYANTRA - Select Fundus Image', ...
    imageFolder);

if isequal(fileName,0)

    fprintf('\nNo image selected.\n');

    screening = [];

    return;

end

imagePath = fullfile(filePath,fileName);

fprintf('\n============================================\n');
fprintf('          NAYANTRA SCREENING SYSTEM\n');
fprintf('============================================\n');

fprintf('\nSelected Image:\n%s\n',imagePath);

%% ============================================================
% 4. READ IMAGE
% =============================================================

inputImage = imread(imagePath);

%% ============================================================
% 5. FUNDUS VALIDATION
% =============================================================

fprintf('\n[1/4] Fundus authenticity check...\n');

validation = validateFundusImage(inputImage);

fprintf('Validation Status : %s\n', ...
    validation.status);

fprintf('Validation Score  : %.0f%%\n', ...
    validation.score);

%% Reject if validation fails

if ~validation.isFundus

    fprintf('\n--------------------------------------------\n');
    fprintf('IMAGE REJECTED\n');
    fprintf('--------------------------------------------\n');

    fprintf('%s\n',validation.message);

    figure( ...
        'Name', ...
        'NAYANTRA - Image Rejected');

    imshow(inputImage);

    title(sprintf( ...
        'IMAGE REJECTED | Validation: %.0f%%', ...
        validation.score));

    screening = struct();

    screening.imageName = fileName;
    screening.imagePath = imagePath;
    screening.validation = validation;
    screening.status = 'REJECTED';

    return;

end

%% ============================================================
% 6. IMAGE QUALITY CHECK
% =============================================================

fprintf('\n[2/4] Image quality check...\n');

imageDouble = im2double(inputImage);

%% Convert grayscale to RGB

if ndims(imageDouble) == 2

    imageDouble = repmat( ...
        imageDouble,[1 1 3]);

end

%% Resize exactly like model input

imageSize = [224 224];

resizedImage = imresize( ...
    imageDouble, ...
    imageSize);

grayImage = rgb2gray(resizedImage);

%% Brightness

brightnessValue = mean(grayImage(:));

%% Contrast

contrastValue = std(grayImage(:));

%% Sharpness

laplacianKernel = [
     0 -1  0
    -1  4 -1
     0 -1  0
];

laplacianImage = imfilter( ...
    grayImage, ...
    laplacianKernel, ...
    'replicate');

sharpnessValue = var( ...
    laplacianImage(:));

%% Quality checks

brightnessPass = ...
    brightnessValue > 0.08 && ...
    brightnessValue < 0.75;

contrastPass = ...
    contrastValue > 0.05;

sharpnessPass = ...
    sharpnessValue > 0.00005;

qualityChecks = [
    brightnessPass
    contrastPass
    sharpnessPass
];

qualityScore = ...
    100 * sum(qualityChecks) / 3;

if qualityScore >= 66.67

    qualityStatus = 'PASS';

else

    qualityStatus = 'REVIEW';

end

fprintf('Brightness : %.4f\n', ...
    brightnessValue);

fprintf('Contrast   : %.4f\n', ...
    contrastValue);

fprintf('Sharpness  : %.6f\n', ...
    sharpnessValue);

fprintf('Quality Score : %.0f%%\n', ...
    qualityScore);

fprintf('Quality Status: %s\n', ...
    qualityStatus);

%% ============================================================
% 7. MODEL INPUT PREPARATION
% =============================================================

fprintf('\n[3/4] Preparing model input...\n');

% IMPORTANT:
% The original ResNet training code used:
%
% augmentedImageDatastore(
%     inputSize(1:2),
%     imds,
%     "ColorPreprocessing","gray2rgb")
%
% Therefore we DO NOT apply CLAHE, gamma correction,
% illumination correction or additional enhancement here.

modelInput = imresize( ...
    inputImage, ...
    imageSize);

%% Handle grayscale images

if ndims(modelInput) == 2

    modelInput = repmat( ...
        modelInput, ...
        [1 1 3]);

end

%% Convert to same data representation

if ~isa(modelInput,'uint8')

    modelInput = im2uint8(modelInput);

end

fprintf('Model input size: %d x %d x %d\n', ...
    size(modelInput,1), ...
    size(modelInput,2), ...
    size(modelInput,3));

%% ============================================================
% 8. LOAD RESNET-18
% =============================================================

fprintf('\n[4/4] Loading ResNet-18...\n');

modelData = load(modelPath);

variableNames = fieldnames(modelData);

net = [];

for i = 1:numel(variableNames)

    candidate = ...
        modelData.(variableNames{i});

    if isa(candidate,'SeriesNetwork') || ...
       isa(candidate,'DAGNetwork') || ...
       isa(candidate,'dlnetwork')

        net = candidate;

        fprintf('Network variable: %s\n', ...
            variableNames{i});

        break;

    end

end

if isempty(net)

    error( ...
        'No trained neural network was found.');

end

%% ============================================================
% 9. DISPLAY NETWORK CLASSES
% =============================================================

classes = net.Layers(end).Classes;

fprintf('\nNetwork classes:\n');

disp(classes);

%% ============================================================
% 10. PREDICTION
% =============================================================

fprintf('Running ResNet-18 prediction...\n');

[predictedLabel,scores] = ...
    classify(net,modelInput);

predictedGrade = char(predictedLabel);

confidence = max(scores) * 100;

%% ============================================================
% 11. GRADE INTERPRETATION
% =============================================================

switch predictedGrade

    case '0'

        gradeDescription = ...
            'No Diabetic Retinopathy';

    case '1'

        gradeDescription = ...
            'Mild Diabetic Retinopathy';

    case '2'

        gradeDescription = ...
            'Moderate Diabetic Retinopathy';

    case '3'

        gradeDescription = ...
            'Severe Diabetic Retinopathy';

    case '4'

        gradeDescription = ...
            'Proliferative Diabetic Retinopathy';

    otherwise

        gradeDescription = ...
            'Unknown Grade';

end

%% ============================================================
% 12. DISPLAY RESULT
% =============================================================

figure( ...
    'Name', ...
    'NAYANTRA - Screening Result');

imshow(modelInput);

title({
    'NAYANTRA Diabetic Retinopathy Screening'
    sprintf('Grade %s - %s', ...
        predictedGrade, ...
        gradeDescription)
    sprintf('Model Confidence: %.2f%%', ...
        confidence)
    }, ...
    'Interpreter','none');

%% ============================================================
% 13. PRINT RESULT
% =============================================================

fprintf('\n============================================\n');
fprintf('          NAYANTRA SCREENING RESULT\n');
fprintf('============================================\n');

fprintf('Image              : %s\n', ...
    fileName);

fprintf('Fundus Validation  : %s\n', ...
    validation.status);

fprintf('Validation Score   : %.0f%%\n', ...
    validation.score);

fprintf('Image Quality      : %s\n', ...
    qualityStatus);

fprintf('Quality Score      : %.0f%%\n', ...
    qualityScore);

fprintf('\n--------------------------------------------\n');

fprintf('Predicted DR Grade : %s\n', ...
    predictedGrade);

fprintf('Interpretation     : %s\n', ...
    gradeDescription);

fprintf('Model Confidence   : %.2f%%\n', ...
    confidence);

fprintf('--------------------------------------------\n');

fprintf('\nClass Probabilities:\n');

for i = 1:numel(scores)

    fprintf( ...
        'Grade %s : %.2f%%\n', ...
        char(classes(i)), ...
        scores(i) * 100);

end

fprintf('============================================\n');

%% ============================================================
% 14. STORE RESULT
% =============================================================

screening = struct();

screening.imageName = fileName;

screening.imagePath = imagePath;

screening.validation = validation;

screening.quality.status = ...
    qualityStatus;

screening.quality.score = ...
    qualityScore;

screening.quality.brightness = ...
    brightnessValue;

screening.quality.contrast = ...
    contrastValue;

screening.quality.sharpness = ...
    sharpnessValue;

screening.prediction.grade = ...
    predictedGrade;

screening.prediction.description = ...
    gradeDescription;

screening.prediction.confidence = ...
    confidence;

screening.prediction.scores = ...
    scores;

screening.status = ...
    'COMPLETED';

end