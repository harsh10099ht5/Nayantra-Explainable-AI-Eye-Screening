function testNayantraAllGrades()
%% testNayantraAllGrades
% NAYANTRA - Automatic 5-Grade Integration Test
%
% Tests one known APTOS image from each DR grade:
%
% Grade 0 -> 002c21358ce6
% Grade 1 -> 0024cdab0c1e
% Grade 2 -> 000c1434d8d7
% Grade 3 -> 0104b032c141
% Grade 4 -> 001639a390f0
%
% This script DOES NOT modify runNayantraScreening.m.
%
% It tests the same integrated pipeline:
% Fundus Validation
%       ->
% Image Quality
%       ->
% Resize
%       ->
% ResNet-18
%
% NOTE:
% This is a verification script for the NAYANTRA prototype.

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

%% Add functions

addpath(functionsFolder);

%% ============================================================
% 2. CHECK FILES
% =============================================================

if ~isfile(modelPath)

    error(['Model not found:' newline modelPath]);

end

%% ============================================================
% 3. KNOWN TEST IMAGES
% =============================================================

imageIDs = {
    '002c21358ce6'
    '0024cdab0c1e'
    '000c1434d8d7'
    '0104b032c141'
    '001639a390f0'
};

actualGrades = [
    0
    1
    2
    3
    4
];

%% ============================================================
% 4. LOAD RESNET-18 MODEL
% =============================================================

fprintf('\n============================================\n');
fprintf('      NAYANTRA 5-GRADE INTEGRATION TEST\n');
fprintf('============================================\n');

fprintf('\nLoading ResNet-18 model...\n');

modelData = load(modelPath);

variableNames = fieldnames(modelData);

net = [];

for i = 1:numel(variableNames)

    candidate = modelData.(variableNames{i});

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

    error('No trained neural network found.');

end

%% ============================================================
% 5. DISPLAY CLASSES
% =============================================================

classes = net.Layers(end).Classes;

fprintf('\nNetwork classes:\n');
disp(classes);

%% ============================================================
% 6. RESULT STORAGE
% =============================================================

predictedGrades = nan(5,1);
confidences = nan(5,1);
validationScores = nan(5,1);
qualityScores = nan(5,1);

%% ============================================================
% 7. TEST EACH GRADE
% =============================================================

for testNumber = 1:5

    actualGrade = actualGrades(testNumber);
    imageID = imageIDs{testNumber};

    fprintf('\n--------------------------------------------\n');
    fprintf('TEST %d / 5\n', testNumber);
    fprintf('--------------------------------------------\n');

    fprintf('Actual Grade : %d\n', actualGrade);
    fprintf('Image        : %s\n', imageID);

    %% --------------------------------------------------------
    % Find image
    % ---------------------------------------------------------

    imagePath = fullfile( ...
        imageFolder, ...
        [imageID '.png']);

    if ~isfile(imagePath)

        fprintf('ERROR: Image not found.\n');
        fprintf('%s\n', imagePath);

        continue;

    end

    %% --------------------------------------------------------
    % Read image
    % ---------------------------------------------------------

    inputImage = imread(imagePath);

    %% --------------------------------------------------------
    % FUNDUS VALIDATION
    % ---------------------------------------------------------

    fprintf('\nFundus validation...\n');

    validation = validateFundusImage(inputImage);

    validationScores(testNumber) = ...
        validation.score;

    fprintf('Status : %s\n', ...
        validation.status);

    fprintf('Score  : %.0f%%\n', ...
        validation.score);

    %% --------------------------------------------------------
    % QUALITY CHECK
    % ---------------------------------------------------------

    fprintf('\nImage quality check...\n');

    imageDouble = im2double(inputImage);

    if ndims(imageDouble) == 2

        imageDouble = repmat( ...
            imageDouble, ...
            [1 1 3]);

    end

    resizedImage = imresize( ...
        imageDouble, ...
        [224 224]);

    grayImage = rgb2gray(resizedImage);

    %% Brightness

    brightnessValue = ...
        mean(grayImage(:));

    %% Contrast

    contrastValue = ...
        std(grayImage(:));

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

    sharpnessValue = ...
        var(laplacianImage(:));

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

    qualityScores(testNumber) = ...
        qualityScore;

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

    fprintf('Quality    : %.0f%% (%s)\n', ...
        qualityScore, ...
        qualityStatus);

    %% --------------------------------------------------------
    % MODEL INPUT
    % ---------------------------------------------------------

    modelInput = imresize( ...
        inputImage, ...
        [224 224]);

    if ndims(modelInput) == 2

        modelInput = repmat( ...
            modelInput, ...
            [1 1 3]);

    end

    %% --------------------------------------------------------
    % RESNET PREDICTION
    % ---------------------------------------------------------

    fprintf('\nResNet-18 prediction...\n');

    [predictedLabel,scores] = ...
        classify(net,modelInput);

    predictedGrade = str2double( ...
        char(predictedLabel));

    confidence = ...
        max(scores) * 100;

    predictedGrades(testNumber) = ...
        predictedGrade;

    confidences(testNumber) = ...
        confidence;

    %% --------------------------------------------------------
    % CHECK RESULT
    % ---------------------------------------------------------

    if predictedGrade == actualGrade

        resultText = 'CORRECT';

    else

        resultText = 'INCORRECT';

    end

    fprintf('Predicted Grade : %d\n', ...
        predictedGrade);

    fprintf('Confidence      : %.2f%%\n', ...
        confidence);

    fprintf('Result          : %s\n', ...
        resultText);

    %% --------------------------------------------------------
    % CLASS PROBABILITIES
    % ---------------------------------------------------------

    fprintf('\nClass probabilities:\n');

    for k = 1:numel(scores)

        fprintf( ...
            'Grade %s : %.2f%%\n', ...
            char(classes(k)), ...
            scores(k) * 100);

    end

end

%% ============================================================
% 8. FINAL SUMMARY
% =============================================================

validTests = ~isnan(predictedGrades);

correctTests = ...
    predictedGrades(validTests) == ...
    actualGrades(validTests);

numberCorrect = ...
    sum(correctTests);

numberTested = ...
    sum(validTests);

if numberTested > 0

    testAccuracy = ...
        100 * numberCorrect / numberTested;

else

    testAccuracy = 0;

end

fprintf('\n\n============================================\n');
fprintf('          FINAL INTEGRATION SUMMARY\n');
fprintf('============================================\n');

fprintf('\n');

fprintf('Actual Grade   Predicted Grade   Confidence\n');
fprintf('--------------------------------------------\n');

for i = 1:5

    if ~isnan(predictedGrades(i))

        fprintf( ...
            '     %d              %d             %.2f%%\n', ...
            actualGrades(i), ...
            predictedGrades(i), ...
            confidences(i));

    else

        fprintf( ...
            '     %d              ERROR          --\n', ...
            actualGrades(i));

    end

end

fprintf('--------------------------------------------\n');

fprintf('Images Tested : %d/5\n', ...
    numberTested);

fprintf('Correct       : %d/5\n', ...
    numberCorrect);

fprintf('5-Image Accuracy: %.2f%%\n', ...
    testAccuracy);

fprintf('\n============================================\n');

if numberCorrect == 5

    fprintf('ALL FIVE TESTS PASSED.\n');

else

    fprintf('%d test(s) require investigation.\n', ...
        5 - numberCorrect);

end

fprintf('============================================\n');

%% ============================================================
% 9. SUMMARY TABLE
% =============================================================

fprintf('\nDetailed Summary:\n\n');

fprintf(['Grade | Prediction | Confidence | ' ...
         'Validation | Quality\n']);

fprintf(['--------------------------------------------' ...
         '----------------\n']);

for i = 1:5

    if ~isnan(predictedGrades(i))

        fprintf( ...
            '  %d   |     %d      |   %6.2f%% |   %6.0f%%   |  %6.0f%%\n', ...
            actualGrades(i), ...
            predictedGrades(i), ...
            confidences(i), ...
            validationScores(i), ...
            qualityScores(i));

    end

end

fprintf('\nTest completed successfully.\n');

end