%% FaultSeverityEstimation_XAxis_withAnomalyDetection.m
% Script per fault severity estimation usando solo l'asse X.
% I file txt contengono 4 colonne, ma si usa soltanto la prima (X).
% Include anche un modulo di anomaly detection per la classe "2" (esteso per gestire le classi base).

%% Parametri e configurazione
FS = 20480;              % frequenza di campionamento (20.48 kHz)
SEGMENT = 1;
SEGMENT_LENGTH = FS * SEGMENT;   % campioni per segmento (1 secondo)
NUM_CLASSES = 7;          % 7 classi (le classi originali 0,1,2,3,4,6,8 vengono rietichettate da 0 a 6)
BATCH_SIZE = 32;
EPOCHS = 15;

% Percorsi (modifica i path in base alla tua struttura)
TRAIN_ROOT = 'B - PHM America 2023 - Dataset/Data_Challenge_PHM2023_training_data';
TEST_ROOT  = 'B - PHM America 2023 - Dataset/Data_Challenge_PHM2023_test_data';

% Mappatura delle cartelle in etichette numeriche
folderLabelMap = containers.Map( ...
    {'Pitting_degradation_level_0 (Healthy)', 'Pitting_degradation_level_1', 'Pitting_degradation_level_2', ...
    'Pitting_degradation_level_3', 'Pitting_degradation_level_4', 'Pitting_degradation_level_6', ...
    'Pitting_degradation_level_8'}, ...
    [0, 1, 2, 3, 4, 6, 8]);

%% Funzione per caricare e segmentare i dati di training (solo asse X)
function [X, y] = loadTrainingData(rootFolder, segmentLength, folderLabelMap)
    X_all = [];
    y_all = [];
    folderNames = keys(folderLabelMap);
    for k = 1:length(folderNames)
        folderName = folderNames{k};
        label = folderLabelMap(folderName);
        folderPath = fullfile(rootFolder, folderName);
        fileList = dir(fullfile(folderPath, '*.txt'));
        fprintf('Carico %d file da %s (label = %d)\n', length(fileList), folderName, label);
        for i = 1:length(fileList)
            filePath = fullfile(folderPath, fileList(i).name);
            try
                % Carica il file e prendi solo la prima colonna (asse X)
                data = load(filePath);
                if size(data,2) >= 1
                    data = data(:,1);
                else
                    error('Formato dati non valido in %s', filePath);
                end
            catch ME
                warning('Errore nella lettura di %s: %s', filePath, ME.message);
                continue;
            end
            nSamples = size(data,1);
            nSegments = floor(nSamples/segmentLength);
            for seg = 1:nSegments
                segment = data((seg-1)*segmentLength+1 : seg*segmentLength);
                if numel(segment) == segmentLength
                    X_all = cat(3, X_all, segment); %#ok<AGROW>
                    y_all = [y_all; label]; %#ok<AGROW>
                end
            end
        end
    end
    % X_all ha dimensioni [segmentLength x 1 x numSegments]
    X = X_all;
    y = y_all;
end

%% Funzione per caricare e segmentare i dati di test (solo asse X)
function [X, fileInfo] = loadTestData(rootFolder, segmentLength)
    X_all = [];
    fileInfo = {};
    fileList = dir(fullfile(rootFolder, '*.txt'));
    fprintf('Carico %d file di test\n', length(fileList));
    for i = 1:length(fileList)
        filePath = fullfile(rootFolder, fileList(i).name);
        try
            data = load(filePath);
            if size(data,2) >= 1
                data = data(:,1);
            else
                error('Formato dati non valido in %s', filePath);
            end
        catch ME
            warning('Errore nella lettura di %s: %s', filePath, ME.message);
            continue;
        end
        nSamples = size(data,1);
        nSegments = floor(nSamples/segmentLength);
        for seg = 1:nSegments
            segment = data((seg-1)*segmentLength+1 : seg*segmentLength);
            if numel(segment) == segmentLength
                X_all = cat(3, X_all, segment); %#ok<AGROW>
                fileInfo{end+1} = fileList(i).name; %#ok<AGROW>
            end
        end
    end
    X = X_all; % [segmentLength x 1 x numSegments]
end

%% Caricamento dati
fprintf('--- Inizio FaultSeverityEstimation_XAxis_withAnomalyDetection.m ---\n');
fprintf('--- Caricamento dati di training ---\n');
[XTrain, yTrain] = loadTrainingData(TRAIN_ROOT, SEGMENT_LENGTH, folderLabelMap);
fprintf('Dati training: %d segmenti di dimensione [%d x 1]\n', size(XTrain,3), size(XTrain,1));

fprintf('--- Caricamento dati di test ---\n');
[XTest, testInfo] = loadTestData(TEST_ROOT, SEGMENT_LENGTH);
fprintf('Dati test: %d segmenti di dimensione [%d x 1]\n', size(XTest,3), size(XTest,1));

%% Normalizzazione
numSegTrain = size(XTrain,3);
meanChannels = zeros(1, size(XTrain,2));
stdChannels = zeros(1, size(XTrain,2));
for ch = 1:size(XTrain,2)
    allData = reshape(XTrain(:,ch,:), [], 1);
    meanChannels(ch) = mean(allData);
    stdChannels(ch) = std(allData);
end
for ch = 1:size(XTrain,2)
    XTrain(:,ch,:) = (XTrain(:,ch,:) - meanChannels(ch)) / stdChannels(ch);
    XTest(:,ch,:) = (XTest(:,ch,:) - meanChannels(ch)) / stdChannels(ch);
end

%% Conversione in formato 4D
numTrain = size(XTrain,3);
XTrain4D = zeros(SEGMENT_LENGTH, 1, 1, numTrain);
for i = 1:numTrain
    XTrain4D(:,:,:,i) = XTrain(:,:,i);
end
numTest = size(XTest,3);
XTest4D = zeros(SEGMENT_LENGTH, 1, 1, numTest);
for i = 1:numTest
    XTest4D(:,:,:,i) = XTest(:,:,i);
end

%% Conversione etichette in categoriche
yTrainCat = categorical(yTrain);

%% Suddivisione Training/Validation
cv = cvpartition(numTrain, 'HoldOut', 0.2);
idxTrain = training(cv);
idxVal = test(cv);
XTrainFinal = XTrain4D(:,:,:,idxTrain);
YTrainFinal = yTrainCat(idxTrain);
XVal = XTrain4D(:,:,:,idxVal);
YVal = yTrainCat(idxVal);

%% Definizione del modello CNN con imageInputLayer
% Ora l'input ha dimensione [SEGMENT_LENGTH x 1 x 1]
inputSize = [SEGMENT_LENGTH, 1, 1];
layers = [ 
    imageInputLayer(inputSize, 'Name', 'input', 'Normalization','none')
    convolution2dLayer([64,1], 16, 'Padding','same', 'Name','conv1')
    reluLayer('Name','relu1')
    maxPooling2dLayer([4,1], 'Stride',[4,1], 'Name','pool1')
    convolution2dLayer([32,1], 32, 'Padding','same', 'Name','conv2')
    reluLayer('Name','relu2')
    maxPooling2dLayer([4,1], 'Stride',[4,1], 'Name','pool2')
    convolution2dLayer([16,1], 64, 'Padding','same', 'Name','conv3')
    reluLayer('Name','relu3')
    maxPooling2dLayer([4,1], 'Stride',[4,1], 'Name','pool3')
    fullyConnectedLayer(128, 'Name','fc1')
    reluLayer('Name','relu_fc1')
    dropoutLayer(0.5, 'Name','dropout')
    fullyConnectedLayer(NUM_CLASSES, 'Name','fc_final')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classOutput')];

%% Opzioni di training
options = trainingOptions('rmsprop',...
    'InitialLearnRate', 0.002,...
    'MaxEpochs', EPOCHS,...
    'MiniBatchSize', BATCH_SIZE,...
    'Shuffle','every-epoch',...
    'ValidationData',{XVal, YVal},...
    'Verbose',true,...
    'Plots','training-progress');

%% Addestramento del modello
net = trainNetwork(XTrainFinal, YTrainFinal, layers, options);

%% Visualizzazione interattiva delle feature con diagnosticFeatureDesigner
% Converti le features in table
featuresTbl = array2table(featuresTrain);
featuresTbl.Label = YTrainFinal;  % aggiungi la colonna delle etichette

% Lancia diagnosticFeatureDesigner
diagnosticFeatureDesigner(featuresTbl);

%% Valutazione sul validation set
YPredVal = classify(net, XVal);
accuracyVal = mean(YPredVal == YVal);
fprintf('Validation accuracy: %.4f\n', accuracyVal);

%% Generazione e salvataggio della matrice di confusione sul validation set
figure;
cm = confusionchart(YVal, YPredVal);
title('Confusion Matrix - Validation Set');
saveas(cm.Parent, 'confusion_matrix.png');
fprintf('Matrice di confusione salvata come confusion_matrix.png\n');

%% Predizione sul test set
YPredTest = classify(net, XTest4D);
YPredProbs = predict(net, XTest4D);
confidences = max(YPredProbs, [], 2);
fprintf('--- Risultati sul test ---\n');
for i = 1:numTest
    fprintf('Segmento %d (file: %s): Predetto livello = %s con confidenza = %.4f\n',...
        i, testInfo{i}, string(YPredTest(i)), confidences(i));
end

%% MODULO DI ANOMALY DETECTION ESTESO PER CLASSI BASE
% Le classi presenti nel training sono: "0", "1", "2", "3", "4", "6", "8".
% I livelli mancanti (non visti in training) sono: "5", "7", "9".
% Se un segmento predetto come "4" risulta anomalo, verrà riassegnato a "5";
% se predetto come "6" e anomalo, a "7"; se predetto come "8" e anomalo, a "9".
baseClasses = {'4','6','8'};
missingMap = containers.Map({'4','6','8'},{'5','7','9'});
featuresTrain = activations(net, XTrainFinal, 'relu_fc1', 'OutputAs', 'rows');
svmModels = containers.Map;
for j = 1:length(baseClasses)
    base = baseClasses{j};
    idx = (string(YTrainFinal) == base);
    if sum(idx) > 0
        featuresBase = featuresTrain(idx, :);
        svmModel = fitcsvm(featuresBase, ones(size(featuresBase,1),1),...
            'KernelFunction','gaussian','Standardize',true,...
            'OutlierFraction',0.05,'ClassNames',1);
        svmModels(base) = svmModel;
        fprintf('Modello SVM addestrato per la classe base %s.\n', base);
    else
        fprintf('Nessun campione per la classe base %s.\n', base);
    end
end
featuresTest = activations(net, XTest4D, 'relu_fc1', 'OutputAs', 'rows');
threshold = -0.1;
for i = 1:numTest
    predLabel = char(YPredTest(i));
    if ismember(predLabel, baseClasses)
        svmModel = svmModels(predLabel);
        [~, score] = predict(svmModel, featuresTest(i,:));
        if score < threshold
            newLabel = missingMap(predLabel);
            fprintf('Segmento %d (file: %s): Rilevata anomalia in classe %s (score=%.4f), riassegnata a %s.\n',...
                i, testInfo{i}, predLabel, score, newLabel);
            YPredTest(i) = categorical({newLabel});
        end
    end
end

%% Esportazione dei risultati del test in submission.csv
submissionTable = table(testInfo', string(YPredTest), confidences,...
    'VariableNames',{'File','Prediction','Confidence'});
writetable(submissionTable, 'submission.csv');
fprintf('File submission.csv generato con %d righe.\n', height(submissionTable));

%% Esportazione dei risultati della validazione in validation_submission.csv
YPredVal = classify(net, XVal);
valIDs = (1:numel(YPredVal))';
validationTable = table(valIDs, string(YPredVal), 'VariableNames',{'Id','Prediction'});
writetable(validationTable, 'validation_submission.csv');
fprintf('File validation_submission.csv generato con %d righe.\n', height(validationTable));
