function [processedImage, preprocessingInfo] = preprocessFundusImage(inputImage)
% preprocessFundusImage
% Preprocesses a fundus image for NAYANTRA screening.
%
% Input:
%   inputImage - Original RGB fundus image
%
% Outputs:
%   processedImage    - Preprocessed RGB image
%   preprocessingInfo - Information about preprocessing operations

if nargin < 1
    error('An input image is required.');
end

% Convert grayscale image to RGB
if ndims(inputImage) == 2
    inputImage = repmat(inputImage, [1 1 3]);
end

% Convert image to uint8
if ~isa(inputImage, 'uint8')
    inputImage = im2uint8(inputImage);
end

% Step 1: Resize image
resizedImage = imresize(inputImage, [224 224]);

% Step 2: Convert RGB image to LAB color space
labImage = rgb2lab(resizedImage);

% Normalize the L channel
luminanceChannel = labImage(:, :, 1) / 100;

% Step 3: Apply CLAHE to improve local contrast
enhancedLuminance = adapthisteq(luminanceChannel, ...
    'NumTiles', [8 8], ...
    'ClipLimit', 0.01);

% Convert enhanced luminance back to LAB scale
labImage(:, :, 1) = enhancedLuminance * 100;

% Step 4: Convert LAB back to RGB
enhancedRGB = lab2rgb(labImage);

% Convert to uint8
enhancedRGB = im2uint8(enhancedRGB);

% Step 5: Mild brightness normalization
% Avoid aggressive illumination correction because it can
% introduce artifacts in the black background.

enhancedDouble = im2double(enhancedRGB);

% Mild gamma adjustment
gammaValue = 0.95;
correctedImage = enhancedDouble .^ gammaValue;

% Create a retinal field-of-view mask
grayImage = rgb2gray(enhancedRGB);
retinalMask = grayImage > 0.05;

% Preserve the original black background
for channel = 1:3
    channelImage = correctedImage(:, :, channel);
    originalChannel = enhancedDouble(:, :, channel);

    channelImage(~retinalMask) = originalChannel(~retinalMask);
    correctedImage(:, :, channel) = channelImage;
end

processedImage = im2uint8(correctedImage);
processedImage = im2uint8(correctedImage);

% Store information
preprocessingInfo.originalSize = size(inputImage);
preprocessingInfo.finalSize = size(processedImage);
preprocessingInfo.operations = {
    'Resize to 224x224'
    'LAB color-space conversion'
    'CLAHE contrast enhancement'
    'Illumination correction'
    };
end