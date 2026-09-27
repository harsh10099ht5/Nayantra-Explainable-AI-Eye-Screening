clc;
clear;
close all;

% Exact project paths
projectFolder = "D:\SIH26038_DR_Project";
imageFolder = fullfile(projectFolder, "data", "APTOS", "train_images");
splitFolder = fullfile(projectFolder, "data", "splits");

% Read existing split CSV files
trainData = readtable(fullfile(splitFolder, "train_split.csv"));
validationData = readtable(fullfile(splitFolder, "validation_split.csv"));
testData = readtable(fullfile(splitFolder, "test_split.csv"));

% Convert labels into categorical format
trainLabels = categorical(trainData.diagnosis);
validationLabels = categorical(validationData.diagnosis);
testLabels = categorical(testData.diagnosis);

% Create image file paths
trainFiles = fullfile(imageFolder, string(trainData.id_code) + ".png");
validationFiles = fullfile(imageFolder, string(validationData.id_code) + ".png");
testFiles = fullfile(imageFolder, string(testData.id_code) + ".png");

% Create the three datastores
imdsTrain = imageDatastore(trainFiles, ...
    "Labels", trainLabels);

imdsValidation = imageDatastore(validationFiles, ...
    "Labels", validationLabels);

imdsTest = imageDatastore(testFiles, ...
    "Labels", testLabels);

% Display sample counts
fprintf("Training images: %d\n", numel(imdsTrain.Files));
fprintf("Validation images: %d\n", numel(imdsValidation.Files));
fprintf("Testing images: %d\n", numel(imdsTest.Files));

% Display label distributions
disp("Training distribution:");
disp(countEachLabel(imdsTrain));

disp("Validation distribution:");
disp(countEachLabel(imdsValidation));

disp("Testing distribution:");
disp(countEachLabel(imdsTest));
