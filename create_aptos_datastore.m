% APTOS dataset paths
csvFile = "D:\SIH26038_DR_Project\data\APTOS\train.csv";
imageFolder = "D:\SIH26038_DR_Project\data\APTOS\train_images";

% Read metadata
data = readtable(csvFile);

% Create complete image paths
imageIDs = string(data.id_code);
imageFiles = fullfile(imageFolder, imageIDs + ".png");

% Convert diagnosis labels into categorical labels
labels = categorical(data.diagnosis);

% Create image datastore
imds = imageDatastore(imageFiles, ...
    "Labels", labels);

% Display datastore information
disp(imds);

% Display label distribution
countEachLabel(imds)