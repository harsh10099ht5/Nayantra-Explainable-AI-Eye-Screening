function result = generateNayantraGradCAM()
%% generateNayantraGradCAM
%
% NAYANTRA - Explainable AI using Grad-CAM
%
% Workflow:
%
% Fundus Image
%      ↓
% Fundus Validation
%      ↓
% ResNet-18
%      ↓
% DR Prediction
%      ↓
% Grad-CAM
%      ↓
% Explainable Heatmap
%
% IMPORTANT:
% This is a research/hackathon prototype and is not
% a clinically validated diagnostic system.

clc;
close all;

%% ============================================================
% 1. PROJECT PATHS
% =============================================================

projectRoot = 'D:\SIH26038_DR_Project';

functionsFolder = fullfile( ...
    projectRoot, ...
    'app', ...
    'functions');

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

    error(['ResNet-18 model not found:' newline ...
        modelPath]);

end

%% ============================================================
% 3. SELECT IMAGE
% =============================================================

[fileName,filePath] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg;*.bmp', ...
    'Fundus Image Files'}, ...
    'NAYANTRA - Select Fundus Image', ...
    imageFolder);

if isequal(fileName,0)

    fprintf('\nNo image selected.\n');

    result = [];

    return;

end

imagePath = fullfile( ...
    filePath, ...
    fileName);

fprintf('\n============================================\n');
fprintf('       NAYANTRA EXPLAINABLE AI MODULE\n');
fprintf('============================================\n');

fprintf('\nImage:\n%s\n',imagePath);

%% ============================================================
% 4. READ IMAGE
% =============================================================

originalImage = imread(imagePath);

%% ============================================================
% 5. FUNDUS VALIDATION
% =============================================================

fprintf('\nChecking fundus authenticity...\n');

validation = validateFundusImage( ...
    originalImage);

fprintf('Validation : %s\n', ...
    validation.status);

fprintf('Score      : %.0f%%\n', ...
    validation.score);

if ~validation.isFundus

    fprintf('\nImage rejected.\n');
    fprintf('%s\n',validation.message);

    result = struct();

    result.status = 'REJECTED';
    result.imageName = fileName;
    result.validation = validation;

    return;

end

%% ============================================================
% 6. PREPARE MODEL INPUT
% =============================================================

fprintf('\nPreparing model input...\n');

modelInput = imresize( ...
    originalImage, ...
    [224 224]);

%% Convert grayscale to RGB

if ndims(modelInput) == 2

    modelInput = repmat( ...
        modelInput, ...
        [1 1 3]);

end

%% Ensure uint8

if ~isa(modelInput,'uint8')

    modelInput = im2uint8(modelInput);

end

%% ============================================================
% 7. LOAD RESNET-18
% =============================================================

fprintf('Loading ResNet-18...\n');

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
        'No trained neural network found in MAT file.');

end

%% ============================================================
% 8. PREDICTION
% =============================================================

fprintf('\nRunning ResNet-18 prediction...\n');

[predictedLabel,scores] = ...
    classify(net,modelInput);

predictedGrade = char(predictedLabel);

confidence = max(scores) * 100;

fprintf('Predicted Grade : %s\n', ...
    predictedGrade);

fprintf('Confidence      : %.2f%%\n', ...
    confidence);

%% ============================================================
% 9. FIND PREDICTED CLASS INDEX
% =============================================================

classes = net.Layers(end).Classes;

predictedClassIndex = find( ...
    classes == predictedLabel);

if isempty(predictedClassIndex)

    error('Predicted class could not be located.');

end

%% ============================================================
% 10. GRAD-CAM
% =============================================================

fprintf('\nGenerating Grad-CAM explanation...\n');

try

    % Grad-CAM for predicted class
    scoreMap = gradCAM( ...
        net, ...
        modelInput, ...
        predictedLabel);

catch ME

    fprintf('\nGrad-CAM generation failed.\n');
    fprintf('MATLAB error:\n%s\n',ME.message);

    fprintf('\nThe model prediction itself is valid.\n');

    result = struct();

    result.status = 'GRADCAM_ERROR';
    result.imageName = fileName;
    result.imagePath = imagePath;
    result.predictedGrade = predictedGrade;
    result.confidence = confidence;
    result.validation = validation;
    result.errorMessage = ME.message;

    return;

end

%% ============================================================
% 11. RESIZE HEATMAP
% =============================================================

scoreMap = imresize( ...
    scoreMap, ...
    [size(originalImage,1), ...
     size(originalImage,2)]);

%% ============================================================
% 12. DISPLAY ORIGINAL IMAGE
% =============================================================

figure( ...
    'Name', ...
    'NAYANTRA - Original Fundus Image');

imshow(originalImage);

title({ ...
    'Original Fundus Image'
    sprintf('Predicted Grade: %s | Confidence: %.2f%%', ...
    predictedGrade, ...
    confidence)}, ...
    'Interpreter','none');

%% ============================================================
% 13. DISPLAY GRAD-CAM
% =============================================================

figure( ...
    'Name', ...
    'NAYANTRA - Grad-CAM Explanation');

imshow(originalImage);

hold on;

imagesc(scoreMap);

axis image off;

colormap jet;

colorbar;

alpha(0.45);

title({ ...
    'NAYANTRA Explainable AI - Grad-CAM'
    sprintf('Grade %s | Confidence %.2f%%', ...
    predictedGrade, ...
    confidence)
    'Highlighted regions influenced the model prediction'}, ...
    'Interpreter','none');

hold off;

%% ============================================================
% 14. DISPLAY SIDE-BY-SIDE STYLE FIGURE
% =============================================================

figure( ...
    'Name', ...
    'NAYANTRA - AI Explanation');

imshow(originalImage);

hold on;

imagesc(scoreMap);

axis image off;

colormap jet;

colorbar;

alpha(0.40);

title( ...
    'Grad-CAM: Model Attention Regions', ...
    'Interpreter','none');

hold off;

%% ============================================================
% 15. GRADE INTERPRETATION
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
% 16. PRINT REPORT
% =============================================================

fprintf('\n============================================\n');
fprintf('       NAYANTRA EXPLAINABLE AI RESULT\n');
fprintf('============================================\n');

fprintf('Image              : %s\n', ...
    fileName);

fprintf('Validation         : %s\n', ...
    validation.status);

fprintf('Validation Score   : %.0f%%\n', ...
    validation.score);

fprintf('\nPredicted Grade    : %s\n', ...
    predictedGrade);

fprintf('Interpretation     : %s\n', ...
    gradeDescription);

fprintf('Model Confidence   : %.2f%%\n', ...
    confidence);

fprintf('\nGrad-CAM Status    : GENERATED\n');

fprintf('============================================\n');

%% ============================================================
% 17. STORE RESULT
% =============================================================

result = struct();

result.status = 'COMPLETED';

result.imageName = fileName;

result.imagePath = imagePath;

result.validation = validation;

result.predictedGrade = predictedGrade;

result.gradeDescription = gradeDescription;

result.confidence = confidence;

result.scores = scores;

result.classes = classes;

result.predictedClassIndex = ...
    predictedClassIndex;

result.gradCAM = scoreMap;

fprintf('\nGrad-CAM generation completed.\n');

end
