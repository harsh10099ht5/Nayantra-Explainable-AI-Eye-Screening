%% View an APTOS Retinal Image

% Load the training CSV file
data = readtable("D:\SIH26038_DR_Project\data\APTOS\train.csv");

% Select the first image ID
imageID = data.id_code{1};

% Get the corresponding DR diagnosis
label = data.diagnosis(1);

% Create the complete image path
imagePath = fullfile( ...
    "D:\SIH26038_DR_Project\data\APTOS\train_images", ...
    imageID + ".png");

% Read the retinal image
img = imread(imagePath);

% Display the image
figure;
imshow(img);

% Display the image ID and diagnosis
title("Image ID: " + imageID + ...
    " | DR Grade: " + string(label));