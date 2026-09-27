%% SIH26038 - Load APTOS Dataset

% Load the APTOS training CSV file
data = readtable("data/APTOS/train.csv");

% Display the size of the dataset
size(data)

% Display the first five rows
head(data,5)

% Display column names
data.Properties.VariableNames

% Display the number of images in each DR grade
tabulate(data.diagnosis)
