function result = validateFundusImage(inputImage)
%% validateFundusImage
%
% NAYANTRA preliminary fundus-image validation gate.
%
% IMPORTANT:
% This is a heuristic engineering filter for a hackathon prototype.
% It is not a clinically validated fundus-image detector.

%% Validate input

if nargin < 1
    error('An input image is required.');
end

if isempty(inputImage)
    error('The input image is empty.');
end

%% Initialize output structure

result.isFundus = false;
result.status = 'REJECT';
result.score = 0;
result.message = '';

result.circularity = 0;
result.fieldAreaRatio = 0;
result.fieldAspectRatio = 0;

result.meanRed = 0;
result.meanGreen = 0;
result.meanBlue = 0;

result.brightness = 0;
result.contrast = 0;
result.darkBorderRatio = 0;

result.circularFieldCheck = false;
result.colorCheck = false;
result.darkBorderCheck = false;
result.brightnessCheck = false;
result.contrastCheck = false;

%% Convert image to RGB

if ndims(inputImage) == 2
    inputImage = repmat(inputImage, [1 1 3]);
end

if size(inputImage, 3) ~= 3
    result.message = ...
        'The image must contain three color channels.';
    return;
end

%% Convert to double and resize

imageDouble = im2double(inputImage);
imageDouble = imresize(imageDouble, [224 224]);

redChannel = imageDouble(:, :, 1);
greenChannel = imageDouble(:, :, 2);
blueChannel = imageDouble(:, :, 3);

grayImage = rgb2gray(imageDouble);

imageHeight = size(grayImage, 1);
imageWidth = size(grayImage, 2);

%% Check 1: Retinal field shape

retinalMask = grayImage > 0.05;

retinalMask = bwareaopen(retinalMask, 500);

connectedComponents = bwconncomp(retinalMask);

largestMask = false(size(retinalMask));

if connectedComponents.NumObjects > 0

    componentSizes = cellfun( ...
        @numel, ...
        connectedComponents.PixelIdxList);

    [~, largestIndex] = max(componentSizes);

    largestMask( ...
        connectedComponents.PixelIdxList{largestIndex}) = true;
end

regionProperties = regionprops( ...
    largestMask, ...
    'Area', ...
    'Perimeter', ...
    'BoundingBox');

if ~isempty(regionProperties)

    areaValue = regionProperties.Area;
    perimeterValue = regionProperties.Perimeter;
    boundingBox = regionProperties.BoundingBox;

    if perimeterValue > 0
        circularity = ...
            (4 * pi * areaValue) / (perimeterValue ^ 2);
    else
        circularity = 0;
    end

    fieldAreaRatio = areaValue / numel(grayImage);

    fieldWidth = boundingBox(3);
    fieldHeight = boundingBox(4);

    if fieldHeight > 0
        fieldAspectRatio = fieldWidth / fieldHeight;
    else
        fieldAspectRatio = 0;
    end

else

    circularity = 0;
    fieldAreaRatio = 0;
    fieldAspectRatio = 0;

end

circularFieldCheck = ...
    circularity > 0.35 && ...
    fieldAreaRatio > 0.20 && ...
    fieldAspectRatio > 0.65 && ...
    fieldAspectRatio < 1.50;

%% Check 2: Fundus-like color distribution

meanRed = mean(redChannel(:));
meanGreen = mean(greenChannel(:));
meanBlue = mean(blueChannel(:));

redGreenDifference = meanRed - meanGreen;
greenBlueDifference = meanGreen - meanBlue;

colorCheck = ...
    redGreenDifference > 0.015 && ...
    greenBlueDifference > 0.005;

%% Check 3: Dark camera border

borderSize = round(0.10 * min(imageHeight, imageWidth));

borderMask = false(imageHeight, imageWidth);

borderMask(1:borderSize, :) = true;
borderMask(end-borderSize+1:end, :) = true;
borderMask(:, 1:borderSize) = true;
borderMask(:, end-borderSize+1:end) = true;

borderPixels = grayImage(borderMask);

darkBorderRatio = mean(borderPixels < 0.12);

darkBorderCheck = darkBorderRatio > 0.08;

%% Check 4: Brightness

brightnessValue = mean(grayImage(:));

brightnessCheck = ...
    brightnessValue > 0.08 && ...
    brightnessValue < 0.75;

%% Check 5: Contrast

contrastValue = std(grayImage(:));

contrastCheck = contrastValue > 0.05;

%% Calculate validation score

checksPassed = [
    circularFieldCheck
    colorCheck
    darkBorderCheck
    brightnessCheck
    contrastCheck
];

result.score = ...
    100 * sum(checksPassed) / numel(checksPassed);

%% Final decision

if darkBorderCheck && sum(checksPassed) >= 4

    result.isFundus = true;
    result.status = 'PASS';

    result.message = ...
        'Image appears compatible with a fundus photograph.';

else

    result.isFundus = false;
    result.status = 'REJECT';

    result.message = ...
        'The image failed the preliminary fundus authenticity checks.';

end

%% Store diagnostic metrics

result.circularity = circularity;
result.fieldAreaRatio = fieldAreaRatio;
result.fieldAspectRatio = fieldAspectRatio;

result.meanRed = meanRed;
result.meanGreen = meanGreen;
result.meanBlue = meanBlue;

result.brightness = brightnessValue;

% Correct line: contrastValue is the numeric variable.
result.contrast = contrastValue;

result.darkBorderRatio = darkBorderRatio;

result.circularFieldCheck = circularFieldCheck;
result.colorCheck = colorCheck;
result.darkBorderCheck = darkBorderCheck;
result.brightnessCheck = brightnessCheck;
result.contrastCheck = contrastCheck;

end