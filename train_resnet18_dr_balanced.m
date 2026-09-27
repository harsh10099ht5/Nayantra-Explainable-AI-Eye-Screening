clc;
clear;
close all;

%% 1. Project paths

projectRoot = "D:\SIH26038_DR_Project";

trainCSV = fullfile( ...
    projectRoot, "data", "splits", "train_split.csv");

validationCSV = fullfile( ...
    projectRoot, "data", "splits", "validation_split.csv");

imageFolder = fullfile( ...
    projectRoot, "data", "APTOS", "train_images");

%% 2. Load training and validation metadata

trainTable = readtable(trainCSV);
validationTable = readtable(validationCSV);

%% 3. Create image datastores

trainImageFiles = fullfile( ...
    imageFolder, string(trainTable.id_code) + ".png");

validationImageFiles = fullfile( ...
    imageFolder, string(validationTable.id_code) + ".png");

imdsTrain = imageDatastore( ...
    trainImageFiles, ...
    "Labels", categorical(trainTable.diagnosis));

imdsValidation = imageDatastore( ...
    validationImageFiles, ...
    "Labels", categorical(validationTable.diagnosis));

disp("Training images: " + numel(imdsTrain.Files));
disp("Validation images: " + numel(imdsValidation.Files));

%% 4. Calculate class weights

classNames = categories(imdsTrain.Labels);
classCounts = countcats(imdsTrain.Labels);

numClasses = numel(classNames);
totalImages = sum(classCounts);

classWeights = totalImages ./ ...
    (numClasses .* classCounts);

disp("Class names:");
disp(classNames);

disp("Class counts:");
disp(classCounts);

disp("Class weights:");
disp(classWeights);

%% 5. Load pretrained ResNet-18

[net, classes] = imagePretrainedNetwork("resnet18");

inputSize = net.Layers(1).InputSize;

lgraph = layerGraph(net);

%% 6. Replace the final fully connected layer

newFCLayer = fullyConnectedLayer(5, ...
    "Name", "fc_dr_balanced", ...
    "WeightLearnRateFactor", 10, ...
    "BiasLearnRateFactor", 10);

lgraph = replaceLayer( ...
    lgraph, "fc1000", newFCLayer);

%% 7. Replace softmax layer

newSoftmaxLayer = softmaxLayer( ...
    "Name", "prob_dr_balanced");

lgraph = replaceLayer( ...
    lgraph, "prob", newSoftmaxLayer);

%% 8. Add class-weighted classification layer

newClassificationLayer = classificationLayer( ...
    "Name", "classification_output_balanced", ...
    "Classes", categorical(classNames), ...
    "ClassWeights", classWeights);

lgraph = addLayers( ...
    lgraph, newClassificationLayer);

lgraph = connectLayers( ...
    lgraph, ...
    "prob_dr_balanced", ...
    "classification_output_balanced");

disp("Class-balanced network created.");

%% 9. Prepare resized datastores

augimdsTrain = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsTrain, ...
    "ColorPreprocessing", "gray2rgb");

augimdsValidation = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsValidation, ...
    "ColorPreprocessing", "gray2rgb");

%% 10. Training options

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

%% 11. Train class-balanced model

disp("Starting class-balanced ResNet-18 training...");

trainedBalancedNet = trainNetwork( ...
    augimdsTrain, ...
    lgraph, ...
    options);

%% 12. Save class-balanced model

modelFolder = fullfile( ...
    projectRoot, "models");

if ~exist(modelFolder, "dir")
    mkdir(modelFolder);
end

balancedModelPath = fullfile( ...
    modelFolder, ...
    "resnet18_dr_balanced_trained.mat");

save(balancedModelPath, ...
    "trainedBalancedNet");

disp("Class-balanced training completed.");
disp("Model saved at:");
disp(balancedModelPath);