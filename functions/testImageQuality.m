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

% Select an image manually
[fileName, filePath] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg', 'Retinal Images (*.png, *.jpg, *.jpeg)'}, ...
    'Select a Fundus Image', ...
    imageFolder);

if isequal(fileName, 0)
    disp('No image selected.');
    return;
end

% Read selected image
imageFullPath = fullfile(filePath, fileName);
inputImage = imread(imageFullPath);

% Run image-quality analysis
quality = checkImageQuality(inputImage);

% Display image and results
figure( ...
    'Name', 'NAYANTRA - Fundus Image Quality Check', ...
    'NumberTitle', 'off', ...
    'Color', 'w');

imshow(inputImage);
title(['Image Quality Status: ', quality.status], ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

% Print report
fprintf('\n============================================\n');
fprintf('       NAYANTRA IMAGE QUALITY REPORT\n');
fprintf('============================================\n');

fprintf('Image Name       : %s\n', fileName);
fprintf('Brightness       : %.4f\n', quality.brightness);
fprintf('Contrast         : %.4f\n', quality.contrast);
fprintf('Sharpness        : %.6f\n', quality.sharpness);
fprintf('Dark Area        : %.2f%%\n', quality.darkPercentage);

fprintf('\nIndividual Checks:\n');
fprintf('Brightness Check : %s\n', passFail(quality.brightnessOK));
fprintf('Contrast Check   : %s\n', passFail(quality.contrastOK));
fprintf('Sharpness Check  : %s\n', passFail(quality.sharpnessOK));
fprintf('Field of View    : %s\n', passFail(quality.fieldOfViewOK));

fprintf('\nOverall Status   : %s\n', quality.status);
fprintf('Message          : %s\n', quality.message);

fprintf('============================================\n');

% Local helper function
function result = passFail(condition)

    if condition
        result = 'PASS';
    else
        result = 'REVIEW';
    end

end