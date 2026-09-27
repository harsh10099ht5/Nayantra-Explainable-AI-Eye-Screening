function report = generateNayantraReport()
%% generateNayantraReport
% NAYANTRA - AI-Assisted Diabetic Retinopathy Screening Report
%
% Complete project pipeline:
% Patient Information
% Fundus Validation
% Image Quality
% ResNet-18 Prediction
% Grad-CAM Explainability
% Professional Screening Report
%
% Research / hackathon prototype.
% Not a clinically validated diagnostic system.

clc;
close all;

%% ============================================================
% 1. PROJECT PATHS
% =============================================================

projectRoot = 'D:\SIH26038_DR_Project';

functionsFolder = fullfile( ...
    projectRoot,'app','functions');

imageFolder = fullfile( ...
    projectRoot,'data','APTOS','train_images');

modelPath = fullfile( ...
    projectRoot,'models','resnet18_dr_trained.mat');

reportsFolder = fullfile( ...
    projectRoot,'results','reports');

addpath(functionsFolder);

if ~exist(reportsFolder,'dir')
    mkdir(reportsFolder);
end

%% ============================================================
% 2. PATIENT INFORMATION
% =============================================================

prompt = {
    'Patient / Demo ID:'
    'Patient Name:'
    'Age:'
    'Screening Date:'
    };

defaultValues = {
    'NAYANTRA-001'
    'Demo Patient'
    'Not Provided'
    datestr(now,'dd-mmm-yyyy')
    };

answer = inputdlg( ...
    prompt, ...
    'NAYANTRA Screening Information', ...
    [1 45], ...
    defaultValues);

if isempty(answer)

    fprintf('\nReport cancelled.\n');

    report = [];

    return;

end

patientID = answer{1};
patientName = answer{2};
patientAge = answer{3};
screeningDate = answer{4};

%% ============================================================
% 3. SELECT FUNDUS IMAGE
% =============================================================

[fileName,filePath] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg;*.bmp','Fundus Image Files'}, ...
    'NAYANTRA - Select Fundus Image', ...
    imageFolder);

if isequal(fileName,0)

    fprintf('\nNo image selected.\n');

    report = [];

    return;

end

imagePath = fullfile(filePath,fileName);

originalImage = imread(imagePath);

%% ============================================================
% 4. FUNDUS VALIDATION
% =============================================================

fprintf('\n============================================\n');
fprintf('       NAYANTRA SCREENING SYSTEM\n');
fprintf('============================================\n');

fprintf('\n[1/4] Fundus authenticity check...\n');

validation = validateFundusImage(originalImage);

fprintf('Validation : %s\n', ...
    validation.status);

fprintf('Score      : %.0f%%\n', ...
    validation.score);

if ~validation.isFundus

    fprintf('\nIMAGE REJECTED\n');
    fprintf('%s\n',validation.message);

    report = struct();

    report.status = 'REJECTED';

    report.patientID = patientID;
    report.patientName = patientName;
    report.patientAge = patientAge;
    report.screeningDate = screeningDate;

    report.imageName = fileName;
    report.imagePath = imagePath;

    report.validation = validation;

    return;

end

%% ============================================================
% 5. IMAGE QUALITY
% =============================================================

fprintf('\n[2/4] Image quality check...\n');

imageDouble = im2double(originalImage);

if ndims(imageDouble) == 2

    imageDouble = repmat( ...
        imageDouble,[1 1 3]);

end

qualityImage = imresize( ...
    imageDouble,[224 224]);

grayImage = rgb2gray(qualityImage);

%% Brightness

brightnessValue = ...
    mean(grayImage(:));

%% Contrast

contrastValue = ...
    std(grayImage(:));

%% Sharpness

laplacianKernel = [
     0 -1  0
    -1  4 -1
     0 -1  0
];

laplacianImage = imfilter( ...
    grayImage, ...
    laplacianKernel, ...
    'replicate');

sharpnessValue = ...
    var(laplacianImage(:));

%% Quality checks

brightnessPass = ...
    brightnessValue > 0.08 && ...
    brightnessValue < 0.75;

contrastPass = ...
    contrastValue > 0.05;

sharpnessPass = ...
    sharpnessValue > 0.00005;

qualityChecks = [
    brightnessPass
    contrastPass
    sharpnessPass
];

qualityScore = ...
    100 * sum(qualityChecks) / 3;

if qualityScore >= 66.67

    qualityStatus = 'PASS';

else

    qualityStatus = 'REVIEW';

end

fprintf('Brightness : %.4f\n', ...
    brightnessValue);

fprintf('Contrast   : %.4f\n', ...
    contrastValue);

fprintf('Sharpness  : %.6f\n', ...
    sharpnessValue);

fprintf('Quality    : %.0f%% (%s)\n', ...
    qualityScore, ...
    qualityStatus);

%% ============================================================
% 6. PREPARE MODEL INPUT
% =============================================================

fprintf('\n[3/4] Preparing model input...\n');

% IMPORTANT:
% Match the original training pipeline.
% Only resize and RGB conversion are used.

modelInput = imresize( ...
    originalImage,[224 224]);

if ndims(modelInput) == 2

    modelInput = repmat( ...
        modelInput,[1 1 3]);

end

if ~isa(modelInput,'uint8')

    modelInput = im2uint8(modelInput);

end

%% ============================================================
% 7. LOAD RESNET-18
% =============================================================

fprintf('\n[4/4] Loading ResNet-18...\n');

if ~isfile(modelPath)

    error(['ResNet-18 model not found:' newline ...
        modelPath]);

end

modelData = load(modelPath);

variableNames = fieldnames(modelData);

net = [];

for i = 1:numel(variableNames)

    candidate = modelData.(variableNames{i});

    if isa(candidate,'SeriesNetwork') || ...
       isa(candidate,'DAGNetwork') || ...
       isa(candidate,'dlnetwork')

        net = candidate;

        fprintf('Network variable: %s\n', ...
            variableNames{i});

        break;

    end

end

if isempty(net)

    error('No trained neural network found.');

end

%% ============================================================
% 8. RESNET PREDICTION
% =============================================================

fprintf('\nRunning ResNet-18 prediction...\n');

[predictedLabel,scores] = ...
    classify(net,modelInput);

predictedGrade = char(predictedLabel);

confidence = max(scores) * 100;

fprintf('Predicted Grade : %s\n', ...
    predictedGrade);

fprintf('Confidence      : %.2f%%\n', ...
    confidence);

%% ============================================================
% 9. GRADE DESCRIPTION
% =============================================================

switch predictedGrade

    case '0'

        gradeDescription = ...
            'No Diabetic Retinopathy';

    case '1'

        gradeDescription = ...
            'Mild Diabetic Retinopathy';

    case '2'

        gradeDescription = ...
            'Moderate Diabetic Retinopathy';

    case '3'

        gradeDescription = ...
            'Severe Diabetic Retinopathy';

    case '4'

        gradeDescription = ...
            'Proliferative Diabetic Retinopathy';

    otherwise

        gradeDescription = ...
            'Unknown Grade';

end

%% ============================================================
% 10. CONFIDENCE LEVEL
% =============================================================

if confidence >= 80

    confidenceLevel = 'High';

elseif confidence >= 60

    confidenceLevel = 'Moderate';

else

    confidenceLevel = 'Low';

end

%% ============================================================
% 11. SCREENING SUMMARY
% =============================================================

switch predictedGrade

    case '0'

        screeningSummary = ...
            'No DR pattern detected by the AI model.';

    case '1'

        screeningSummary = ...
            'Mild DR pattern detected by the AI model.';

    case '2'

        screeningSummary = ...
            'Moderate DR pattern detected by the AI model.';

    case '3'

        screeningSummary = ...
            'Severe DR pattern detected by the AI model.';

    case '4'

        screeningSummary = ...
            'Proliferative DR pattern detected by the AI model.';

    otherwise

        screeningSummary = ...
            'Model result requires further review.';

end

%% ============================================================
% 12. GRAD-CAM
% =============================================================

fprintf('\nGenerating Grad-CAM explanation...\n');

try

    scoreMap = gradCAM( ...
        net, ...
        modelInput, ...
        predictedLabel);

    scoreMap = imresize( ...
        scoreMap, ...
        [size(originalImage,1), ...
         size(originalImage,2)]);

    gradCAMStatus = 'GENERATED';

    fprintf('Grad-CAM generated successfully.\n');

catch ME

    scoreMap = [];

    gradCAMStatus = 'FAILED';

    fprintf('Grad-CAM failed:\n');

    fprintf('%s\n', ...
        ME.message);

end

%% ============================================================
% 13. CREATE REPORT WINDOW
% =============================================================

screenSize = get(0,'ScreenSize');

screenWidth = screenSize(3);
screenHeight = screenSize(4);

reportWidth = min(1450, ...
    round(screenWidth * 0.90));

reportHeight = min(900, ...
    round(screenHeight * 0.82));

reportFigure = figure( ...
    'Name','NAYANTRA Screening Report', ...
    'NumberTitle','off', ...
    'Color','white', ...
    'Units','pixels', ...
    'Position',[100 100 ...
    reportWidth reportHeight], ...
    'WindowStyle','normal', ...
    'MenuBar','none', ...
    'ToolBar','figure');

try

    set(reportFigure, ...
        'WindowState','normal');

catch

end

movegui(reportFigure,'center');

%% ============================================================
% 14. TITLE
% =============================================================

annotation( ...
    reportFigure,'textbox', ...
    [0.04 0.925 0.92 0.045], ...
    'String','NAYANTRA', ...
    'FontSize',23, ...
    'FontWeight','bold', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'Color',[0.05 0.20 0.35], ...
    'EdgeColor','none');

annotation( ...
    reportFigure,'textbox', ...
    [0.04 0.885 0.92 0.032], ...
    'String', ...
    'AI-ASSISTED DIABETIC RETINOPATHY SCREENING REPORT', ...
    'FontSize',11.5, ...
    'FontWeight','bold', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'Color',[0.25 0.25 0.25], ...
    'EdgeColor','none');

%% ============================================================
% 15. PATIENT INFORMATION BOX
% =============================================================

annotation( ...
    reportFigure,'textbox', ...
    [0.045 0.760 0.425 0.120], ...
    'String',sprintf([ ...
    'PATIENT / SCREENING INFORMATION\n\n' ...
    'ID: %s\n' ...
    'Name: %s\n' ...
    'Age: %s   |   Date: %s'], ...
    patientID, ...
    patientName, ...
    patientAge, ...
    screeningDate), ...
    'FontSize',9.5, ...
    'VerticalAlignment','top', ...
    'Color',[0.08 0.08 0.08], ...
    'BackgroundColor',[0.96 0.96 0.96], ...
    'EdgeColor',[0.35 0.35 0.35], ...
    'LineWidth',1.2);

%% ============================================================
% 16. AI SCREENING RESULT BOX
% =============================================================

annotation( ...
    reportFigure,'textbox', ...
    [0.53 0.735 0.425 0.145], ...
    'String',sprintf([ ...
    'AI SCREENING RESULT\n\n' ...
    'DR Grade: %s\n' ...
    '%s\n' ...
    'Confidence: %.2f%%\n' ...
    'Level: %s'], ...
    predictedGrade, ...
    gradeDescription, ...
    confidence, ...
    confidenceLevel), ...
    'FontSize',9.5, ...
    'FontWeight','bold', ...
    'VerticalAlignment','top', ...
    'Color',[0.08 0.08 0.08], ...
    'BackgroundColor',[0.96 0.96 0.96], ...
    'EdgeColor',[0.35 0.35 0.35], ...
    'LineWidth',1.2);

%% ============================================================
% 17. ORIGINAL FUNDUS IMAGE
% =============================================================

ax1 = axes( ...
    'Parent',reportFigure, ...
    'Position',[0.080 0.365 0.365 0.270], ...
    'Box','on', ...
    'LineWidth',2.5, ...
    'XColor',[0.10 0.10 0.10], ...
    'YColor',[0.10 0.10 0.10]);

imshow(originalImage,'Parent',ax1);

axis(ax1,'image');
axis(ax1,'off');

title(ax1, ...
    'Original Fundus', ...
    'FontSize',10.5, ...
    'FontWeight','bold', ...
    'Color',[0.15 0.15 0.15]);

%% ============================================================
% 18. GRAD-CAM IMAGE
% =============================================================

ax2 = axes( ...
    'Parent',reportFigure, ...
    'Position',[0.555 0.365 0.365 0.270], ...
    'Box','on', ...
    'LineWidth',2.5, ...
    'XColor',[0.10 0.10 0.10], ...
    'YColor',[0.10 0.10 0.10]);

imshow(originalImage,'Parent',ax2);

if ~isempty(scoreMap)

    hold(ax2,'on');

    imagesc(ax2,scoreMap);

    axis(ax2,'image');
    axis(ax2,'off');

    colormap(ax2,jet);

    alpha(0.38);

    hold(ax2,'off');

end

title(ax2, ...
    'Grad-CAM Explainable AI', ...
    'FontSize',10.5, ...
    'FontWeight','bold', ...
    'Color',[0.15 0.15 0.15]);

%% ============================================================
% 19. IMAGE VALIDATION & QUALITY BOX
% =============================================================

annotation( ...
    reportFigure,'textbox', ...
    [0.045 0.155 0.425 0.160], ...
    'String',sprintf([ ...
    'IMAGE VALIDATION & QUALITY\n\n' ...
    'Fundus : %s (%0.f%%)\n' ...
    'Quality: %s (%0.f%%)\n' ...
    'Brightness: %.4f\n' ...
    'Contrast: %.4f\n' ...
    'Sharpness: %.6f'], ...
    validation.status, ...
    validation.score, ...
    qualityStatus, ...
    qualityScore, ...
    brightnessValue, ...
    contrastValue, ...
    sharpnessValue), ...
    'FontSize',8.8, ...
    'VerticalAlignment','top', ...
    'Color',[0.08 0.08 0.08], ...
    'BackgroundColor',[0.97 0.97 0.97], ...
    'EdgeColor',[0.35 0.35 0.35], ...
    'LineWidth',1.2);

%% ============================================================
% 20. MODEL CLASS PROBABILITIES BOX
% =============================================================

classes = net.Layers(end).Classes;

probabilityText = sprintf( ...
    'MODEL CLASS PROBABILITIES\n\n');

for i = 1:numel(scores)

    probabilityText = sprintf( ...
        '%sGrade %s: %.2f%%\n', ...
        probabilityText, ...
        char(classes(i)), ...
        scores(i)*100);

end

annotation( ...
    reportFigure,'textbox', ...
    [0.53 0.155 0.425 0.160], ...
    'String',probabilityText, ...
    'FontSize',8.8, ...
    'VerticalAlignment','top', ...
    'Color',[0.08 0.08 0.08], ...
    'BackgroundColor',[0.97 0.97 0.97], ...
    'EdgeColor',[0.35 0.35 0.35], ...
    'LineWidth',1.2);

%% ============================================================
% 21. AI SCREENING SUMMARY
% =============================================================

annotation( ...
    reportFigure,'textbox', ...
    [0.045 0.085 0.91 0.050], ...
    'String',sprintf( ...
    'AI SCREENING SUMMARY:  %s', ...
    screeningSummary), ...
    'FontSize',9.5, ...
    'FontWeight','bold', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'Color',[0.05 0.20 0.35], ...
    'BackgroundColor',[0.93 0.96 0.98], ...
    'EdgeColor',[0.35 0.50 0.65], ...
    'LineWidth',1.2);

%% ============================================================
% 22. GRAD-CAM NOTE
% =============================================================

annotation( ...
    reportFigure,'textbox', ...
    [0.045 0.050 0.91 0.025], ...
    'String', ...
    ['Grad-CAM shows image regions contributing to the model prediction. ' ...
     'It does not independently confirm a specific retinal lesion.'], ...
    'FontSize',7.5, ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'Color',[0.25 0.25 0.25], ...
    'EdgeColor','none');

%% ============================================================
% 23. DISCLAIMER
% =============================================================

annotation( ...
    reportFigure,'textbox', ...
    [0.045 0.018 0.91 0.025], ...
    'String', ...
    ['NAYANTRA is an AI-assisted research prototype. ' ...
     'The result is a model prediction and is not a standalone medical diagnosis. ' ...
     'Appropriate clinical review is required.'], ...
    'FontSize',7.5, ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'Color',[0.40 0.40 0.40], ...
    'EdgeColor','none');

%% ============================================================
% 24. SAVE PDF
% =============================================================

safePatientID = regexprep( ...
    patientID, ...
    '[^a-zA-Z0-9_-]', ...
    '_');

timestamp = datestr( ...
    now,'yyyymmdd_HHMMSS');

pdfName = sprintf( ...
    'NAYANTRA_Report_%s_%s.pdf', ...
    safePatientID, ...
    timestamp);

pdfPath = fullfile( ...
    reportsFolder,pdfName);

fprintf('\nSaving PDF report...\n');

try

    exportgraphics( ...
        reportFigure, ...
        pdfPath, ...
        'ContentType','image', ...
        'Resolution',200);

    pdfStatus = 'SAVED';

    fprintf('PDF saved successfully:\n');
    fprintf('%s\n',pdfPath);

catch ME

    pdfStatus = 'FAILED';

    fprintf('PDF export failed:\n');
    fprintf('%s\n',ME.message);

end

%% ============================================================
% 25. FINAL COMMAND WINDOW REPORT
% =============================================================

fprintf('\n============================================\n');
fprintf('       NAYANTRA FINAL SCREENING REPORT\n');
fprintf('============================================\n');

fprintf('Patient ID       : %s\n', ...
    patientID);

fprintf('Patient Name     : %s\n', ...
    patientName);

fprintf('Age              : %s\n', ...
    patientAge);

fprintf('Screening Date   : %s\n', ...
    screeningDate);

fprintf('\nImage            : %s\n', ...
    fileName);

fprintf('\nFundus Validation: %s (%.0f%%)\n', ...
    validation.status, ...
    validation.score);

fprintf('Image Quality    : %s (%.0f%%)\n', ...
    qualityStatus, ...
    qualityScore);

fprintf('\nDR Grade         : %s\n', ...
    predictedGrade);

fprintf('Interpretation   : %s\n', ...
    gradeDescription);

fprintf('Confidence       : %.2f%%\n', ...
    confidence);

fprintf('Confidence Level : %s\n', ...
    confidenceLevel);

fprintf('Grad-CAM         : %s\n', ...
    gradCAMStatus);

fprintf('PDF Report       : %s\n', ...
    pdfStatus);

fprintf('============================================\n');

%% ============================================================
% 26. RETURN STRUCTURE
% =============================================================

report = struct();

report.status = 'COMPLETED';

report.patientID = patientID;
report.patientName = patientName;
report.patientAge = patientAge;
report.screeningDate = screeningDate;

report.imageName = fileName;
report.imagePath = imagePath;

report.validation = validation;

report.quality.status = qualityStatus;
report.quality.score = qualityScore;
report.quality.brightness = brightnessValue;
report.quality.contrast = contrastValue;
report.quality.sharpness = sharpnessValue;

report.prediction.grade = predictedGrade;
report.prediction.description = gradeDescription;
report.prediction.confidence = confidence;
report.prediction.confidenceLevel = confidenceLevel;
report.prediction.scores = scores;
report.prediction.classes = classes;

report.explainability.status = gradCAMStatus;
report.explainability.gradCAM = scoreMap;

report.pdfPath = pdfPath;

fprintf('\nNAYANTRA report generation completed.\n');

end