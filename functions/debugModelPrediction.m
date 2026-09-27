function debugModelPrediction()
%% debugModelPrediction
% Automatically tests one known APTOS image from each DR grade.
%
% Grade:
% 0 = No DR
% 1 = Mild
% 2 = Moderate
% 3 = Severe
% 4 = Proliferative DR

clc;
close all;

%% ============================================================
% PATHS
% =============================================================

projectRoot = 'D:\SIH26038_DR_Project';

modelPath = fullfile( ...
    projectRoot, ...
    'models', ...
    'resnet18_dr_trained.mat');

csvPath = fullfile( ...
    projectRoot, ...
    'data', ...
    'APTOS', ...
    'train.csv');

imageFolder = fullfile( ...
    projectRoot, ...
    'data', ...
    'APTOS', ...
    'train_images');

%% ============================================================
% LOAD MODEL
% =============================================================

fprintf('\nLoading ResNet-18 model...\n');

data = load(modelPath);

names = fieldnames(data);

net = [];

for i = 1:numel(names)

    candidate = data.(names{i});

    if isa(candidate,'SeriesNetwork') || ...
       isa(candidate,'DAGNetwork') || ...
       isa(candidate,'dlnetwork')

        net = candidate;

        fprintf('Network variable: %s\n', names{i});

        break;
    end
end

if isempty(net)
    error('No neural network found in MAT file.');
end

%% ============================================================
% DISPLAY MODEL CLASSES
% =============================================================

fprintf('\nNetwork classes:\n');

classes = net.Layers(end).Classes;

disp(classes);

%% ============================================================
% LOAD APTOS CSV
% =============================================================

fprintf('\nLoading APTOS labels...\n');

T = readtable(csvPath);

disp(T.Properties.VariableNames);

%% ============================================================
% FIND IMAGE ID AND DIAGNOSIS COLUMNS
% =============================================================

imageColumn = 'id_code';
labelColumn = 'diagnosis';

if ~ismember(imageColumn,T.Properties.VariableNames)
    error('Column "id_code" was not found in train.csv.');
end

if ~ismember(labelColumn,T.Properties.VariableNames)
    error('Column "diagnosis" was not found in train.csv.');
end

%% ============================================================
% TEST ONE IMAGE FROM EACH GRADE
% =============================================================

fprintf('\n============================================\n');
fprintf('       NAYANTRA MODEL DIAGNOSTIC TEST\n');
fprintf('============================================\n');

for actualGrade = 0:4

    %% Find images belonging to this grade

    rows = find(T.(labelColumn) == actualGrade);

    if isempty(rows)

        fprintf('\nNo image found for Grade %d.\n', ...
            actualGrade);

        continue;

    end

    %% Select first available image

    selectedRow = rows(1);

    imageID = string(T.(imageColumn)(selectedRow));

    %% Try possible extensions

    possibleFiles = {
        fullfile(imageFolder, imageID + ".png")
        fullfile(imageFolder, imageID + ".jpg")
        fullfile(imageFolder, imageID + ".jpeg")
    };

    imagePath = '';

    for j = 1:length(possibleFiles)

        if isfile(possibleFiles{j})

            imagePath = possibleFiles{j};

            break;

        end

    end

    if isempty(imagePath)

        fprintf('\nGrade %d image not found: %s\n', ...
            actualGrade, imageID);

        continue;

    end

    %% Read image

    originalImage = imread(imagePath);

    %% Resize only
    % IMPORTANT:
    % No CLAHE, gamma correction or other preprocessing here.
    % We are testing the trained model directly.

    testImage = imresize(originalImage,[224 224]);

    %% Predict

    [predictedLabel,scores] = ...
        classify(net,testImage);

    %% Convert predicted label

    predictedGrade = char(predictedLabel);

    %% Get predicted confidence

    confidence = max(scores) * 100;

    %% Display result

    fprintf('\n--------------------------------------------\n');

    fprintf('Actual Grade    : %d\n', ...
        actualGrade);

    fprintf('Image            : %s\n', ...
        imageID);

    fprintf('Predicted Grade : %s\n', ...
        predictedGrade);

    fprintf('Confidence       : %.2f%%\n', ...
        confidence);

    fprintf('\nClass probabilities:\n');

    for k = 1:numel(classes)

        fprintf('Grade %s : %.2f%%\n', ...
            char(classes(k)), ...
            scores(k)*100);

    end

    fprintf('--------------------------------------------\n');

    %% Display image

    figure('Name', ...
        sprintf('APTOS Grade %d Test',actualGrade));

    imshow(originalImage);

    title(sprintf( ...
        'Actual: Grade %d | Predicted: Grade %s | %.2f%%', ...
        actualGrade, ...
        predictedGrade, ...
        confidence));

end

fprintf('\n============================================\n');
fprintf('             TEST COMPLETE\n');
fprintf('============================================\n');

end