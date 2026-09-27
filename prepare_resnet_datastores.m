clc;
clear;
close all;

% Load ResNet-18 network
[net, classes] = imagePretrainedNetwork("resnet18");

% Get ResNet-18 input size
inputSize = net.Layers(1).InputSize;

% Exact APTOS dataset paths
projectFolder = "D:\SIH26038_DR_Project";
imageFolder = fullfile(projectFolder, "data", "APTOS", "train_images");
splitFolder = fullfile(projectFolder, "data", "splits");

% Read existing split CSV files
trainData = readtable(fullfile(splitFolder, "train_split.csv"));
validationData = readtable(fullfile(splitFolder, "validation_split.csv"));
testData = readtable(fullfile(splitFolder, "test_split.csv"));

% Convert labels
trainLabels = categorical(trainData.diagnosis);
validationLabels = categorical(validationData.diagnosis);
testLabels = categorical(testData.diagnosis);

% Create image paths
trainFiles = fullfile(imageFolder, string(trainData.id_code) + ".png");
validationFiles = fullfile(imageFolder, string(validationData.id_code) + ".png");
testFiles = fullfile(imageFolder, string(testData.id_code) + ".png");

% Create image datastores
imdsTrain = imageDatastore(trainFiles, "Labels", trainLabels);
imdsValidation = imageDatastore(validationFiles, "Labels", validationLabels);
imdsTest = imageDatastore(testFiles, "Labels", testLabels);

% Resize images for ResNet-18
augimdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain);
augimdsValidation = augmentedImageDatastore(inputSize(1:2), imdsValidation);
augimdsTest = augmentedImageDatastore(inputSize(1:2), imdsTest);

% Display confirmation
disp("ResNet-18 input size:");
disp(inputSize);

fprintf("Training images: %d\n", numel(imdsTrain.Files));
fprintf("Validation images: %d\n", numel(imdsValidation.Files));
fprintf("Testing images: %d\n", numel(imdsTest.Files));

disp("All datastores are ready.");