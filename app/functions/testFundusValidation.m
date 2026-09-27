%% testFundusValidation.m

clc;
close all;

%% Project paths

projectRoot = 'D:\SIH26038_DR_Project';

functionsFolder = fullfile(projectRoot, 'app', 'functions');
imageFolder = fullfile(projectRoot, 'data', 'APTOS', 'train_images');

addpath(functionsFolder);

%% Select image

[fileName, filePath] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files'}, ...
    'Select a fundus image', ...
    imageFolder);

if isequal(fileName, 0)
    fprintf('No image selected. Test cancelled.\n');
    return;
end

%% Read selected image

imageFullPath = fullfile(filePath, fileName);

fprintf('Selected image: %s\n', imageFullPath);

inputImage = imread(imageFullPath);

%% Validate image

result = validateFundusImage(inputImage);

%% Display image

figure('Name', 'NAYANTRA Fundus Validation');

imshow(inputImage);

title(sprintf('%s | Score: %.0f%%', ...
    result.status, result.score), ...
    'Interpreter', 'none');

%% Print report

fprintf('\n============================================\n');
fprintf('       NAYANTRA FUNDUS VALIDATION REPORT\n');
fprintf('============================================\n');

fprintf('Image Name       : %s\n', fileName);
fprintf('Image Path       : %s\n', imageFullPath);
fprintf('Validation Status: %s\n', result.status);
fprintf('Validation Score : %.0f%%\n', result.score);

fprintf('\n----- Image Metrics -----\n');

fprintf('Brightness       : %.4f\n', ...
    result.brightness);

fprintf('Contrast         : %.4f\n', ...
    result.contrast);

fprintf('Dark Border      : %.2f%%\n', ...
    result.darkBorderRatio * 100);

fprintf('Mean Red         : %.4f\n', ...
    result.meanRed);

fprintf('Mean Green       : %.4f\n', ...
    result.meanGreen);

fprintf('Mean Blue        : %.4f\n', ...
    result.meanBlue);

fprintf('Circularity      : %.4f\n', ...
    result.circularity);

fprintf('Field Area Ratio : %.4f\n', ...
    result.fieldAreaRatio);

fprintf('Field Aspect Ratio: %.4f\n', ...
    result.fieldAspectRatio);

fprintf('\n----- Individual Checks -----\n');

fprintf('Circular Field   : %s\n', ...
    checkText(result.circularFieldCheck));

fprintf('Color Check      : %s\n', ...
    checkText(result.colorCheck));

fprintf('Dark Border Check: %s\n', ...
    checkText(result.darkBorderCheck));

fprintf('Brightness Check : %s\n', ...
    checkText(result.brightnessCheck));

fprintf('Contrast Check   : %s\n', ...
    checkText(result.contrastCheck));

fprintf('\n----- Message -----\n');
fprintf('%s\n', result.message);

fprintf('============================================\n');

%% Helper function

function output = checkText(value)

    if value
        output = 'PASS';
    else
        output = 'FAIL';
    end

end