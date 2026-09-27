function quality = checkImageQuality(inputImage)
% checkImageQuality
% Performs basic fundus image quality checks.
%
% Input:
%   inputImage - RGB or grayscale image
%
% Output:
%   quality - structure containing quality metrics and status

    if nargin < 1
        error('An input image is required.');
    end

    % Convert image to double format
    imageDouble = im2double(inputImage);

    % Convert grayscale image to RGB if necessary
    if ndims(imageDouble) == 2
        rgbImage = repmat(imageDouble, [1 1 3]);
    else
        rgbImage = imageDouble;
    end

    % Convert to grayscale for measurements
    grayImage = rgb2gray(rgbImage);

    % Basic measurements
    brightness = mean(grayImage(:));
    contrastValue = std(grayImage(:));

    % Blur estimation using Laplacian variance
    laplacianKernel = [0 1 0; 1 -4 1; 0 1 0];
    laplacianImage = imfilter(grayImage, laplacianKernel, 'replicate');
    sharpness = var(laplacianImage(:));

    % Estimate dark background percentage
    darkPixels = grayImage < 0.05;
    darkPercentage = 100 * nnz(darkPixels) / numel(grayImage);

    % Quality thresholds
    brightnessMinimum = 0.08;
    brightnessMaximum = 0.75;
    contrastMinimum = 0.08;
    sharpnessMinimum = 0.0005;
    darkPercentageMaximum = 85;

    % Individual checks
    brightnessOK = ...
        brightness >= brightnessMinimum && ...
        brightness <= brightnessMaximum;

    contrastOK = contrastValue >= contrastMinimum;

    sharpnessOK = sharpness >= sharpnessMinimum;

    fieldOfViewOK = darkPercentage <= darkPercentageMaximum;

    % Overall quality decision
    quality.isAcceptable = ...
        brightnessOK && ...
        contrastOK && ...
        sharpnessOK && ...
        fieldOfViewOK;

    % Store measurements
    quality.brightness = brightness;
    quality.contrast = contrastValue;
    quality.sharpness = sharpness;
    quality.darkPercentage = darkPercentage;

    % Store individual results
    quality.brightnessOK = brightnessOK;
    quality.contrastOK = contrastOK;
    quality.sharpnessOK = sharpnessOK;
    quality.fieldOfViewOK = fieldOfViewOK;

    % Generate messages
    messages = {};

    if ~brightnessOK
        if brightness < brightnessMinimum
            messages{end+1} = 'Image is too dark.';
        else
            messages{end+1} = 'Image is too bright.';
        end
    end

    if ~contrastOK
        messages{end+1} = 'Image contrast is low.';
    end

    if ~sharpnessOK
        messages{end+1} = 'Image may be blurred.';
    end

    if ~fieldOfViewOK
        messages{end+1} = 'Retinal field of view may be insufficient.';
    end

    if quality.isAcceptable
        quality.status = 'PASS';
        quality.message = 'Image quality is acceptable for screening.';
    else
        quality.status = 'REVIEW';
        quality.message = strjoin(messages, ' ');
    end
end