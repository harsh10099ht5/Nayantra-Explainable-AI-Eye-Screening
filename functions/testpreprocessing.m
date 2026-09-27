clc;
clear;
close all;

projectRoot = 'D:\SIH26038_DR_Project';

addpath(fullfile(projectRoot, 'app', 'functions'));

imageFolder = fullfile( ...
    projectRoot, ...
    'data', ...
    'APTOS', ...
    'train_images');

[fileName, filePath] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg', 'Retinal Images'}, ...
    'Select a Fundus Image', ...
    imageFolder);

if isequal(fileName, 0)
    disp('No image selected.');
    return;
end

imagePath = fullfile(filePath, fileName);
originalImage = imread(imagePath);

[processedImage, preprocessingInfo] = ...
    preprocessFundusImage(originalImage);

figure( ...
    'Name', 'NAYANTRA - Fundus Preprocessing', ...
    'NumberTitle', 'off', ...
    'Color', 'w');

subplot(1, 2, 1);
imshow(originalImage);
title('Original Fundus Image');

subplot(1, 2, 2);
imshow(processedImage);
title('Preprocessed Fundus Image');

fprintf('\n===== PREPROCESSING REPORT =====\n');
fprintf('Image Name: %s\n', fileName);
fprintf('Final Image Size: %d x %d\n', ...
    size(processedImage, 1), ...
    size(processedImage, 2));

fprintf('\nOperations Applied:\n');

for i = 1:numel(preprocessingInfo.operations)
    fprintf('%d. %s\n', ...
        i, preprocessingInfo.operations{i});
end

fprintf('================================\n');