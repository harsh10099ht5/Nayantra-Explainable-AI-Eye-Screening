clc;
clear;
close all;

% Load pretrained ResNet-18
[net, classes] = imagePretrainedNetwork("resnet18");

% Convert network into layer graph
lgraph = layerGraph(net);

% Display original final layers
disp("Original final layers:");
disp(lgraph.Layers(end-5:end));

% Replace ImageNet fully connected layer
newFCLayer = fullyConnectedLayer(5, ...
    "Name", "fc_dr", ...
    "WeightLearnRateFactor", 10, ...
    "BiasLearnRateFactor", 10);

lgraph = replaceLayer(lgraph, "fc1000", newFCLayer);

% Replace softmax layer
newSoftmaxLayer = softmaxLayer("Name", "prob_dr");

lgraph = replaceLayer(lgraph, "prob", newSoftmaxLayer);

% Display modified final layers
disp("Modified final layers:");
disp(lgraph.Layers(end-5:end));

% Open network architecture
analyzeNetwork(lgraph);