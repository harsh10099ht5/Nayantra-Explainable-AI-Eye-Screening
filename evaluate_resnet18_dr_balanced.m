clc;
clear;
close all;

%% ============================================================
%  Evaluate Class-Balanced ResNet-18 for Diabetic Retinopathy
%  Dataset: APTOS 2019
% =============================================================

%% 1. Define paths

rootDir = "D:\SIH26038_DR_Project";

imageDir = fullfile( ...
    rootDir, ...
    "data", ...
    "APTOS", ...
    "train_images");

splitDir = fullfile( ...
    rootDir, ...
    "data", ...
    "splits");

modelPath = fullfile( ...
    rootDir, ...
    "models", ...
    "resnet18_dr_balanced_trained.mat");

resultsDir = fullfile( ...
    rootDir, ...
    "results");

%% 2. Check paths

if ~isfolder(rootDir)
    error("Root folder not found: %s", rootDir);
end

if ~isfolder(imageDir)
    error("Image folder not found: %s", imageDir);
end

if ~isfolder(splitDir)
    error("Split folder not found: %s", splitDir);
end

if ~isfile(modelPath)
    error("Balanced model file not found: %s", modelPath);
end

if ~isfolder(resultsDir)
    mkdir(resultsDir);
end

fprintf("Root folder: %s\n", rootDir);
fprintf("Image folder: %s\n", imageDir);
fprintf("Split folder: %s\n", splitDir);
fprintf("Model file: %s\n\n", modelPath);

%% 3. Load trained balanced model

load(modelPath, "trainedBalancedNet");

disp("Balanced ResNet-18 model loaded successfully.");

%% 4. Load test split

testCsvPath = fullfile( ...
    splitDir, ...
    "test_split.csv");

if ~isfile(testCsvPath)
    error("Test split file not found: %s", testCsvPath);
end

testTable = readtable(testCsvPath);

fprintf("Test CSV loaded: %s\n", testCsvPath);
fprintf("Test images: %d\n\n", height(testTable));

%% 5. Verify CSV columns

disp("Columns in test CSV:");
disp(testTable.Properties.VariableNames);

requiredColumns = ["id_code", "diagnosis"];

availableColumns = string( ...
    testTable.Properties.VariableNames);

for i = 1:numel(requiredColumns)

    if ~any(availableColumns == requiredColumns(i))
        error( ...
            "Required column missing: %s", ...
            requiredColumns(i));
    end

end

%% 6. Create test image paths

testImageFiles = fullfile( ...
    imageDir, ...
    string(testTable.id_code) + ".png");

testLabels = categorical(testTable.diagnosis);

%% 7. Verify image files

missingImages = ~isfile(testImageFiles);

if any(missingImages)

    fprintf( ...
        "Missing image count: %d\n", ...
        sum(missingImages));

    disp("First missing image paths:");

    missingPaths = testImageFiles(missingImages);

    disp(missingPaths(1:min(10, numel(missingPaths))));

    error("Some test images are missing.");
end

disp("All test images were found.");

%% 8. Create image datastore

imdsTest = imageDatastore( ...
    testImageFiles, ...
    "Labels", testLabels);

%% 9. Read network input size

inputSize = trainedBalancedNet.Layers(1).InputSize;

fprintf("Network input size: ");
disp(inputSize);

%% 10. Prepare test datastore

augimdsTest = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsTest, ...
    "ColorPreprocessing", ...
    "gray2rgb");

%% 11. Predict test labels

disp("Predicting test images...");

YPred = classify( ...
    trainedBalancedNet, ...
    augimdsTest);

YTrue = imdsTest.Labels;

disp("Prediction completed.");

%% 12. Calculate overall accuracy

testAccuracy = mean(YPred == YTrue) * 100;

fprintf("\n============================================\n");
fprintf("Balanced ResNet-18 Test Accuracy: %.3f%%\n", ...
    testAccuracy);
fprintf("============================================\n\n");

%% 13. Generate confusion matrix

figure;

confusionchart( ...
    YTrue, ...
    YPred);

title( ...
    "Class-Balanced ResNet-18 - Test Confusion Matrix");

confusionMatrixPath = fullfile( ...
    resultsDir, ...
    "resnet18_balanced_confusion_matrix.png");

saveas( ...
    gcf, ...
    confusionMatrixPath);

fprintf( ...
    "Confusion matrix saved to:\n%s\n\n", ...
    confusionMatrixPath);

%% 14. Calculate confusion matrix and metrics

classNames = categories(YTrue);
classNames = classNames(:);

numClasses = numel(classNames);

cm = confusionmat(YTrue, YPred);

precision = zeros(numClasses, 1);
recall = zeros(numClasses, 1);
f1Score = zeros(numClasses, 1);

for i = 1:numClasses

    truePositive = cm(i, i);

    falsePositive = sum(cm(:, i)) - truePositive;

    falseNegative = sum(cm(i, :)) - truePositive;

    % Precision
    if (truePositive + falsePositive) == 0
        precision(i) = 0;
    else
        precision(i) = ...
            truePositive / ...
            (truePositive + falsePositive);
    end

    % Recall
    if (truePositive + falseNegative) == 0
        recall(i) = 0;
    else
        recall(i) = ...
            truePositive / ...
            (truePositive + falseNegative);
    end

    % F1-score
    if (precision(i) + recall(i)) == 0
        f1Score(i) = 0;
    else
        f1Score(i) = ...
            2 * precision(i) * recall(i) / ...
            (precision(i) + recall(i));
    end

end

%% 15. Create metrics table safely

% Ensure every column is a column vector with 5 rows
classColumn = cellstr(classNames(:));
precisionColumn = precision(:) * 100;
recallColumn = recall(:) * 100;
f1Column = f1Score(:) * 100;

% Display dimensions for verification
fprintf("\nTable column sizes:\n");
fprintf("Class:     %d rows\n", numel(classColumn));
fprintf("Precision: %d rows\n", numel(precisionColumn));
fprintf("Recall:    %d rows\n", numel(recallColumn));
fprintf("F1-score:  %d rows\n", numel(f1Column));

% Create table using older MATLAB-compatible syntax
metricsTable = table( ...
    classColumn, ...
    precisionColumn, ...
    recallColumn, ...
    f1Column, ...
    'VariableNames', ...
    { ...
    'Class', ...
    'Precision_Percent', ...
    'Recall_Percent', ...
    'F1Score_Percent' ...
    });

disp("============================================");
disp("Balanced Model Class-Wise Metrics");
disp("============================================");

disp(metricsTable);

%% 16. Calculate macro averages

macroPrecision = mean(precision) * 100;
macroRecall = mean(recall) * 100;
macroF1 = mean(f1Score) * 100;

fprintf("\n============================================\n");
fprintf("Macro Precision: %.3f%%\n", macroPrecision);
fprintf("Macro Recall:    %.3f%%\n", macroRecall);
fprintf("Macro F1-score:  %.3f%%\n", macroF1);
fprintf("============================================\n\n");

%% 17. Save MATLAB results

matResultsPath = fullfile( ...
    resultsDir, ...
    "resnet18_balanced_test_results.mat");

save( ...
    matResultsPath, ...
    "testAccuracy", ...
    "YPred", ...
    "YTrue", ...
    "cm", ...
    "precision", ...
    "recall", ...
    "f1Score", ...
    "macroPrecision", ...
    "macroRecall", ...
    "macroF1", ...
    "metricsTable");

fprintf( ...
    "MATLAB results saved to:\n%s\n\n", ...
    matResultsPath);

%% 18. Save CSV metrics

csvResultsPath = fullfile( ...
    resultsDir, ...
    "resnet18_balanced_class_metrics.csv");

writetable( ...
    metricsTable, ...
    csvResultsPath);

fprintf( ...
    "CSV metrics saved to:\n%s\n\n", ...
    csvResultsPath);

disp("Balanced model evaluation completed successfully.");