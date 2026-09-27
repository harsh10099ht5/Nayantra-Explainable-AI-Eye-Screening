clc;
clear;
close all;

%% 1. Project paths

projectRoot = "D:\SIH26038_DR_Project";

trainCSV = fullfile( ...
    projectRoot, "data", "splits", "train_split.csv");

validationCSV = fullfile( ...
    projectRoot, "data", "splits", "validation_split.csv");

testCSV = fullfile( ...
    projectRoot, "data", "splits", "test_split.csv");

imageFolder = fullfile( ...
    projectRoot, "data", "APTOS", "train_images");

%% 2. Load split CSV files

trainTable = readtable(trainCSV);
validationTable = readtable(validationCSV);
testTable = readtable(testCSV);

% Display column names for confirmation
disp("CSV columns:");
disp(trainTable.Properties.VariableNames);

%% 3. Create image datastores

% Important:
% The CSV column is named id_code, not id.

trainImageFiles = fullfile( ...
    imageFolder, string(trainTable.id_code) + ".png");

validationImageFiles = fullfile( ...
    imageFolder, string(validationTable.id_code) + ".png");

testImageFiles = fullfile( ...
    imageFolder, string(testTable.id_code) + ".png");

imdsTrain = imageDatastore( ...
    trainImageFiles, ...
    "Labels", categorical(trainTable.diagnosis));

imdsValidation = imageDatastore( ...
    validationImageFiles, ...
    "Labels", categorical(validationTable.diagnosis));

imdsTest = imageDatastore( ...
    testImageFiles, ...
    "Labels", categorical(testTable.diagnosis));

disp("Datastores created successfully.");
disp("Training images: " + numel(imdsTrain.Files));
disp("Validation images: " + numel(imdsValidation.Files));
disp("Testing images: " + numel(imdsTest.Files));

%% 4. Load pretrained ResNet-18

[net, classes] = imagePretrainedNetwork("resnet18");

inputSize = net.Layers(1).InputSize;

disp("ResNet-18 input size:");
disp(inputSize);

%% 5. Modify ResNet-18 for five DR classes

lgraph = layerGraph(net);

% Replace the original 1000-class fully connected layer
newFCLayer = fullyConnectedLayer(5, ...
    "Name", "fc_dr", ...
    "WeightLearnRateFactor", 10, ...
    "BiasLearnRateFactor", 10);

lgraph = replaceLayer( ...
    lgraph, "fc1000", newFCLayer);

% Replace the original softmax layer
newSoftmaxLayer = softmaxLayer( ...
    "Name", "prob_dr");

lgraph = replaceLayer( ...
    lgraph, "prob", newSoftmaxLayer);

% Add classification output layer
newClassificationLayer = classificationLayer( ...
    "Name", "classification_output");

lgraph = addLayers( ...
    lgraph, newClassificationLayer);

% Connect softmax to classification output
lgraph = connectLayers( ...
    lgraph, "prob_dr", "classification_output");

disp("ResNet-18 modified for five DR classes.");

%% 6. Prepare resized image datastores

augimdsTrain = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsTrain, ...
    "ColorPreprocessing", "gray2rgb");

augimdsValidation = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsValidation, ...
    "ColorPreprocessing", "gray2rgb");

augimdsTest = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsTest, ...
    "ColorPreprocessing", "gray2rgb");

disp("Image datastores resized successfully.");

%% 7. Set training options

miniBatchSize = 32;

validationFrequency = max(1, ...
    floor(numel(imdsTrain.Files) / miniBatchSize));

options = trainingOptions("sgdm", ...
    "MiniBatchSize", miniBatchSize, ...
    "MaxEpochs", 5, ...
    "InitialLearnRate", 1e-4, ...
    "Shuffle", "every-epoch", ...
    "ValidationData", augimdsValidation, ...
    "ValidationFrequency", validationFrequency, ...
    "Verbose", true, ...
    "Plots", "training-progress");

%% 8. Train the network

disp("Starting ResNet-18 training...");
disp("Please wait. Training may take some time.");

trainedNet = trainNetwork( ...
    augimdsTrain, ...
    lgraph, ...
    options);

%% 9. Save the trained model

modelFolder = fullfile( ...
    projectRoot, "models");

if ~exist(modelFolder, "dir")
    mkdir(modelFolder);
end

modelPath = fullfile( ...
    modelFolder, "resnet18_dr_trained.mat");

save(modelPath, "trainedNet");

disp("Training completed successfully.");
disp("Trained model saved at:");
disp(modelPath);