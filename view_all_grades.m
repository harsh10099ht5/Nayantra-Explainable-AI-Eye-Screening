%% View One Image From Each DR Grade

% Load the APTOS training CSV
data = readtable("D:\SIH26038_DR_Project\data\APTOS\train.csv");

% Path to the training images
imageFolder = "D:\SIH26038_DR_Project\data\APTOS\train_images";

% Create a new figure
figure;

% Loop through all 5 DR grades
for grade = 0:4

    % Find the first image having this DR grade
    index = find(data.diagnosis == grade, 1);

    % Get the image ID
    imageID = data.id_code{index};

    % Create the complete image path
    imagePath = fullfile(imageFolder, imageID + ".png");

    % Read the image
    img = imread(imagePath);

    % Create a subplot
    subplot(1,5,grade+1);

    % Display the image
    imshow(img);

    % Give the image a title
    title("Grade " + string(grade));
end