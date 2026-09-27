% Select the first APTOS image
imageID = string(data.id_code(1));

% Get its complete path
imagePath = fullfile( ...
    "D:\SIH26038_DR_Project\data\APTOS\train_images", ...
    imageID + ".png");

% Read the original retinal image
originalImage = imread(imagePath);

% Get ResNet-18 input size
inputSize = net.Layers(1).InputSize;

% Resize the image
resizedImage = imresize(originalImage, inputSize(1:2));

% Display original and resized images
figure;

subplot(1,2,1);
imshow(originalImage);
title("Original Image");

subplot(1,2,2);
imshow(resizedImage);
title("Resized for ResNet-18");

% Display image dimensions
disp("Original image size:");
disp(size(originalImage));

disp("Resized image size:");
disp(size(resizedImage));