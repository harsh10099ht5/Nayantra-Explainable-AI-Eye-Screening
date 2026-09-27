
%% SIH26038 - Create and Save Dataset Split
% MATLAB environment: D:\SIH26038_DR_Project

% Move to the existing project folder
cd("D:\SIH26038_DR_Project");

% Load the APTOS training CSV
data = readtable("data/APTOS/train.csv");

% Convert diagnosis into categorical labels
data.diagnosis = categorical(data.diagnosis);

% Create stratified 80% training and 20% temporary split
cv1 = cvpartition(data.diagnosis, "HoldOut", 0.20);

trainData = data(training(cv1), :);
tempData = data(test(cv1), :);

% Split temporary data into 50% validation and 50% testing
cv2 = cvpartition(tempData.diagnosis, "HoldOut", 0.50);

validationData = tempData(training(cv2), :);
testData = tempData(test(cv2), :);

% Create the split folder
if ~isfolder("data/splits")
    mkdir("data/splits");
end

% Save the three dataset tables
writetable(trainData, "data/splits/train_split.csv");
writetable(validationData, "data/splits/validation_split.csv");
writetable(testData, "data/splits/test_split.csv");

% Display sample counts
fprintf("Training samples: %d\n", height(trainData));
fprintf("Validation samples: %d\n", height(validationData));
fprintf("Testing samples: %d\n", height(testData));

disp("Dataset splits saved successfully.");