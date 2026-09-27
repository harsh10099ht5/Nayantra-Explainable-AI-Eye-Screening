clc;
clear;
close all;

%% 1. Project paths

projectRoot = "D:\SIH26038_DR_Project";

modelPath = fullfile( ...
    projectRoot, "models", "resnet18_dr_trained.mat");

testCSV = fullfile( ...
    projectRoot, "data", "splits", "test_split.csv");

imageFolder = fullfile( ...
    projectRoot, "data", "APTOS", "train_images");

%% 2. Load trained model

loadedData = load(modelPath);

trainedNet = loadedData.trainedNet;

disp("Trained model loaded successfully.");

%% 3. Load test metadata

testTable = readtable(testCSV);

testImageFiles = fullfile( ...
    imageFolder, string(testTable.id_code) + ".png");

%% 4. Create test datastore

imdsTest = imageDatastore( ...
    testImageFiles, ...
    "Labels", categorical(testTable.diagnosis));

disp("Test datastore created.");
disp("Testing images: " + numel(imdsTest.Files));

%% 5. Prepare test images for ResNet-18

inputSize = trainedNet.Layers(1).InputSize;

augimdsTest = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsTest, ...
    "ColorPreprocessing", "gray2rgb");

%% 6. Predict test labels

disp("Running predictions on the test set...");

YPred = classify(trainedNet, augimdsTest);
YTest = imdsTest.Labels;

%% 7. Calculate test accuracy

testAccuracy = mean(YPred == YTest) * 100;

disp("==============================================");
disp("Final Test Accuracy: " + testAccuracy + "%");
disp("==============================================");

%% 8. Display confusion matrix

figure;

confusionchart(YTest, YPred);

title("ResNet-18 Diabetic Retinopathy Test Confusion Matrix");

%% 9. Calculate class-wise metrics

classNames = categories(YTest);
classNames = string(classNames(:));

confusionMatrix = confusionmat(YTest, YPred);

numClasses = numel(classNames);

precision = zeros(numClasses, 1);
recall = zeros(numClasses, 1);
f1Score = zeros(numClasses, 1);

for i = 1:numClasses

    truePositive = confusionMatrix(i, i);

    falsePositive = sum(confusionMatrix(:, i)) - truePositive;

    falseNegative = sum(confusionMatrix(i, :)) - truePositive;

    precision(i) = truePositive / ...
        max(truePositive + falsePositive, 1);

    recall(i) = truePositive / ...
        max(truePositive + falseNegative, 1);

    f1Score(i) = 2 * ...
        (precision(i) * recall(i)) / ...
        max(precision(i) + recall(i), eps);

end

%% 10. Create class-wise results table

resultsTable = table( ...
    classNames, ...
    precision * 100, ...
    recall * 100, ...
    f1Score * 100, ...
    'VariableNames', { ...
    'DR_Grade', ...
    'Precision_Percent', ...
    'Recall_Percent', ...
    'F1_Score_Percent'});

disp("Class-wise evaluation results:");
disp(resultsTable);

%% 11. Save evaluation results

resultsFolder = fullfile( ...
    projectRoot, "results");

if ~exist(resultsFolder, "dir")
    mkdir(resultsFolder);
end

save(fullfile(resultsFolder, ...
    "resnet18_test_results.mat"), ...
    "testAccuracy", ...
    "confusionMatrix", ...
    "resultsTable");

writetable(resultsTable, fullfile( ...
    resultsFolder, ...
    "resnet18_class_metrics.csv"));

disp("Evaluation results saved successfully.");
disp("Results folder:");
disp(resultsFolder);