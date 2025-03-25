%% FaultSeverityEstimation_ImageInput_withAnomalyDetection.m
% Script per fault severity estimation trattando ogni segmento come "immagine"
% con dimensioni [20000 x 3 x 1]. I file txt contengono 4 colonne, si usano le prime 3 (X, Y, Z).
% Include anche un modulo di anomaly detection per la classe "2".

%% Preparazione dei dati
% Per processare i file di training:
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\Pitting_degradation_level_0 (Healthy)\');
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\Pitting_degradation_level_1\');
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\Pitting_degradation_level_2\');
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\Pitting_degradation_level_3\');
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\Pitting_degradation_level_4\');
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\Pitting_degradation_level_6\');
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\Pitting_degradation_level_8\');

% Per processare i file di test:
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_test_data\');

% Per processare i file di validation:
%processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_validation_data\');

%% Parametri e configurazione
FS = 20480;              % frequenza di campionamento (20.48 kHz)
SEGMENT = 1;
SEGMENT_LENGTH = FS * SEGMENT;   % campioni per segmento (1 secondo)
NUM_CLASSES = 7;          % 7 classi (le classi originali 0,1,2,3,4,6,8 vengono rietichettate da 0 a 6)
BATCH_SIZE = 32;
EPOCHS = 15;

% Percorsi
TRAIN_ROOT = 'B - PHM America 2023 - Dataset/Data_Challenge_PHM2023_training_data';
TEST_ROOT  = 'B - PHM America 2023 - Dataset/Data_Challenge_PHM2023_test_data';
VALIDATION_ROOT = 'B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_validation_data';

% Mappatura delle cartelle in etichette numeriche
folderLabelMap = containers.Map( ...
    {'Pitting_degradation_level_0 (Healthy)', 'Pitting_degradation_level_1', 'Pitting_degradation_level_2', ...
    'Pitting_degradation_level_3', 'Pitting_degradation_level_4', 'Pitting_degradation_level_6', ...
    'Pitting_degradation_level_8'}, ...
    [0, 1, 2, 3, 4, 6, 8]);

%% Funzione per caricare e segmentare i dati di training
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
                % Carica il file e prendi le prime 3 colonne (X, Y, Z)
                data = load(filePath);
                if size(data,2) >= 3
                    data = data(:,1:3);
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
                segment = data((seg-1)*segmentLength+1 : seg*segmentLength, :);
                if size(segment,1) == segmentLength
                    X_all = cat(3, X_all, segment);
                    y_all = [y_all; label];
                end
            end
        end
    end
    % X_all ha dimensioni [segmentLength x 3 x numSegments]
    X = X_all;
    y = y_all;
end

%% Funzione per caricare e segmentare i dati di test
function [X, fileInfo] = loadTestData(rootFolder, segmentLength)
    X_all = [];
    fileInfo = {};
    fileList = dir(fullfile(rootFolder, '*.txt'));
    fprintf('Carico %d file di test\n', length(fileList));
    for i = 1:length(fileList)
        filePath = fullfile(rootFolder, fileList(i).name);
        try
            data = load(filePath);
            if size(data,2) >= 3
                data = data(:,1:3);
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
            segment = data((seg-1)*segmentLength+1 : seg*segmentLength, :);
            if size(segment,1) == segmentLength
                X_all = cat(3, X_all, segment);
                fileInfo{end+1} = fileList(i).name;
            end
        end
    end
    X = X_all; % [segmentLength x 3 x numSegments]
end

%% Caricamento dati
fprintf('--- Inizio complete_cnn_svm.m ---\n');
fprintf('\n');

% ------------------- Elaborazione dati di TRAINING -------------------
fprintf('--- Caricamento dati di training ---\n');
[XTrain, yTrain] = loadTrainingData(TRAIN_ROOT, SEGMENT_LENGTH, folderLabelMap);
fprintf('Dati training: %d segmenti di dimensione [%d x %d]\n', size(XTrain,3), size(XTrain,1), size(XTrain,2));

% ------------------- Elaborazione dati di TEST -------------------
fprintf('--- Caricamento dati di test ---\n');
[XTest, testInfo] = loadTestData(TEST_ROOT, SEGMENT_LENGTH);
fprintf('Dati test (circa 3 per file): %d segmenti di dimensione [%d x %d]\n', size(XTest,3), size(XTest,1), size(XTest,2));

% ------------------- Elaborazione dati di VALIDAZIONE -------------------
fprintf('--- Caricamento dati di validazione ---\n');
[XValidation, validationInfo] = loadTestData(VALIDATION_ROOT, SEGMENT_LENGTH);
fprintf('Dati validazione: %d segmenti di dimensione [%d x %d]\n', size(XValidation,3), size(XValidation,1), size(XValidation,2));

%% Normalizzazione
% Calcola media e std per ogni canale sui dati di training
numSegTrain = size(XTrain,3);
meanChannels = zeros(1, size(XTrain,2));
stdChannels  = zeros(1, size(XTrain,2));
for ch = 1:size(XTrain,2)
    allData = reshape(XTrain(:,ch,:), [], 1);
    meanChannels(ch) = mean(allData);
    stdChannels(ch) = std(allData);
end

% Applica normalizzazione a TRAINING, TEST e VALIDAZIONE
for ch = 1:size(XTrain,2)
    XTrain(:,ch,:) = (XTrain(:,ch,:) - meanChannels(ch)) / stdChannels(ch);
    XTest(:,ch,:)  = (XTest(:,ch,:)  - meanChannels(ch)) / stdChannels(ch);
    XValidation(:,ch,:) = (XValidation(:,ch,:) - meanChannels(ch)) / stdChannels(ch);
end

%% Conversione dei dati in formato 4D
% I dati di training, che attualmente hanno dimensioni [20000 x 3 x N], verranno convertiti
% in un array 4D di dimensioni [20000, 3, 1, N]
convert4D = @(X) reshape(X, size(X,1), size(X,2), 1, size(X,3));

XTrain4D = convert4D(XTrain);
XTest4D = convert4D(XTest);
XValidation4D = convert4D(XValidation);

% Definizione del numero di segmenti per ogni set
numTrain = size(XTrain4D, 4);
numTest = size(XTest4D, 4);
numValidation = size(XValidation4D, 4);

%% Conversione delle etichette in variabili categoriche
yTrainCat = categorical(yTrain);

%% Suddivisione Training/Validation
cv = cvpartition(numTrain, 'HoldOut', 0.2);
idxTrain = training(cv);
idxVal   = test(cv);

XTrainFinal = XTrain4D(:,:,:,idxTrain);
YTrainFinal = yTrainCat(idxTrain);
XVal = XTrain4D(:,:,:,idxVal);
YVal = yTrainCat(idxVal);

%% Definizione del modello CNN con imageInputLayer
inputSize = [SEGMENT_LENGTH, 3, 1];
layers = [ ...
    imageInputLayer(inputSize, 'Name','input','Normalization','none')
    convolution2dLayer([64,3], 16, 'Padding','same','Name','conv1')
    reluLayer('Name','relu1')
    maxPooling2dLayer([4,1],'Stride',[4,1],'Name','pool1')
    convolution2dLayer([32,1], 32, 'Padding','same','Name','conv2')
    reluLayer('Name','relu2')
    maxPooling2dLayer([4,1],'Stride',[4,1],'Name','pool2')
    convolution2dLayer([16,1], 64, 'Padding','same','Name','conv3')
    reluLayer('Name','relu3')
    maxPooling2dLayer([4,1],'Stride',[4,1],'Name','pool3')
    fullyConnectedLayer(128, 'Name','fc1')
    reluLayer('Name','relu_fc1')
    dropoutLayer(0.5, 'Name','dropout')
    fullyConnectedLayer(NUM_CLASSES, 'Name','fc_final')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classOutput')];

%% Opzioni di training
options = trainingOptions('rmsprop', ...
    'InitialLearnRate', 0.002, ...
    'MaxEpochs', EPOCHS, ...
    'MiniBatchSize', BATCH_SIZE, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XVal, YVal}, ...
    'Verbose',true, ...
    'Plots','training-progress');

%% Addestramento del modello
net = trainNetwork(XTrainFinal, YTrainFinal, layers, options);

%% Visualizzazione interattiva delle feature con diagnosticFeatureDesigner
% Estrai le feature dai dati di training dal layer 'relu_fc1'
featuresTrain = activations(net, XTrainFinal, 'relu_fc1', 'OutputAs', 'rows');
% Avvia diagnosticFeatureDesigner per esplorare le feature insieme alle etichette
diagnosticFeatureDesigner(featuresTrain, cellstr(YTrainFinal));

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
    fprintf('Segmento %d (file: %s): Predetto livello = %s con confidenza = %.4f\n', ...
        i, testInfo{i}, string(YPredTest(i)), confidences(i));
end

%% Predizione sul validation set
YPredValidation = classify(net, XValidation4D);
YPredProbsVal = predict(net, XValidation4D);
confidencesVal = max(YPredProbsVal, [], 2);

fprintf('--- Risultati sul validation set ---\n');
for i = 1:numValidation
    fprintf('Segmento %d (file: %s): Predetto livello = %s con confidenza = %.4f\n', ...
        i, validationInfo{i}, string(YPredValidation(i)), confidencesVal(i));
end

%% MODULO DI ANOMALY DETECTION ESTESO PER CLASSI BASE
% Le classi presenti nel training sono: "0", "1", "2", "3", "4", "6", "8".
% I livelli mancanti (non visti in training) sono: "5", "7", "9".
% Quindi, se un segmento predetto come "4" risulta anomalo, verrà riassegnato a "5";
% se predetto come "6" e anomalo, a "7"; se predetto come "8" e anomalo, a "9".

% Definiamo le classi base e la mappa per le classi mancanti:
baseClasses = {'4', '6', '8'};
missingMap = containers.Map({'4', '6', '8'}, {'5', '7', '9'});

% Estraiamo le feature dai dati di training dal layer 'relu_fc1'
featuresTrain = activations(net, XTrainFinal, 'relu_fc1', 'OutputAs', 'rows');

% Addestriamo un one-class SVM per ciascuna classe base
svmModels = containers.Map;
for j = 1:length(baseClasses)
    base = baseClasses{j};
    idx = (string(YTrainFinal) == base);
    if sum(idx) > 0
        featuresBase = featuresTrain(idx, :);
        svmModel = fitcsvm(featuresBase, ones(size(featuresBase,1),1), ...
            'KernelFunction','gaussian','Standardize',true, ...
            'OutlierFraction',0.05,'ClassNames',1);
        svmModels(base) = svmModel;
        fprintf('Modello SVM addestrato per la classe base %s.\n', base);
    else
        fprintf('Nessun campione per la classe base %s.\n', base);
    end
end

threshold = -0.1;  % Soglia per lo score dell'SVM

% Funzione di supporto per applicare l'anomaly detection
function YPredOut = applyAnomalyDetection(YPredIn, features, info, baseClasses, missingMap, svmModels, threshold)
    YPredOut = YPredIn;  % inizialmente le etichette rimangono invariate
    for i = 1:length(YPredIn)
        predLabel = char(YPredIn(i));
        if ismember(predLabel, baseClasses)
            svmModel = svmModels(predLabel);
            [~, score] = predict(svmModel, features(i,:));
            if score < threshold
                newLabel = missingMap(predLabel);
                fprintf('Segmento %d (file: %s): Anomalia in %s (score=%.4f), riassegnata a %s.\n', ...
                    i, info{i}, predLabel, score, newLabel);
                YPredOut(i) = categorical({newLabel});
            end
        end
    end
end

% Applico l'anomaly detection ai dati di TEST
featuresTest = activations(net, XTest4D, 'relu_fc1', 'OutputAs', 'rows');
YPredTest = applyAnomalyDetection(YPredTest, featuresTest, testInfo, baseClasses, missingMap, svmModels, threshold);

% Applico l'anomaly detection ai dati di VALIDAZIONE
featuresValidation = activations(net, XValidation4D, 'relu_fc1', 'OutputAs', 'rows');
YPredValidation = applyAnomalyDetection(YPredValidation, featuresValidation, validationInfo, baseClasses, missingMap, svmModels, threshold);

%% --- Creazione submission.csv in formato PHM Challenge ---

% Le classi "viste" nel training e il corrispondente indice di colonna (1-based) 
%  per prob_0 ... prob_10
% Vi sono 3 samples per file
class_labels_seen    = [0,1,2,3,4,6,8];  
class_idx_in_probs   = [1,2,3,4,5,7,9];  % Esempio: label 0 -> colonna 1, label 1->colonna2, ecc

% Le classi mancanti e la mappa tra classe base -> classe mancante
%  (4->5, 6->7, 8->9)
XTest4D = convert4D(XTest);

numTest = size(XTest4D,4);
prob_matrix_test = zeros(numTest, 11);  % colonne per prob_0 ... prob_10
confidence_binary_test = zeros(numTest,1);

for i = 1:numTest
    % Estrae le probabilità "raw" per il campione corrente (1 x 7)
    rawProbs = YPredProbs(i,:);
    % Converte l'etichetta predetta in carattere (es. '0','1',...)
    predLabelChar = char(YPredTest(i));
    % Converte l'etichetta in formato numerico per confronti
    numericPred = str2double(predLabelChar);
    
    % Calcola la "confidence binaria": se la massima probabilità supera 0.7, setta a 1, altrimenti 0
    if max(rawProbs) > 0.7
        confidence_binary_test(i) = 1;
    else
        confidence_binary_test(i) = 0;
    end
    
    % Caso A: la classe predetta è "vista" (non riassegnata), cioè non è una delle classi mancanti ('5','7','9')
    if ~ismember(predLabelChar, {'5','7','9'})
        % Trova l'indice della classe nella lista delle classi viste
        idx_seen = find(class_labels_seen == numericPred);
        if isempty(idx_seen)
            % Se non trova l'indice (caso improbabile) assegna tutta la probabilità alla prima colonna
            prob_matrix_test(i,1) = 1;
        else
            % Altrimenti, determina la colonna corrispondente nella submission
            col_out = class_idx_in_probs(idx_seen);
            prob_matrix_test(i, col_out) = 1;
        end
    else
        % Caso B: la classe predetta è "mancante" (è stata riassegnata tramite anomaly detection)
        % Determina la classe "base" originale da cui è stata riassegnata:
        switch predLabelChar
            case '5', base = '4';
            case '7', base = '6';
            case '9', base = '8';
        end
        % Converte la base in formato numerico
        baseNum = str2double(base);
        % Trova l'indice della classe base nella lista delle classi viste
        idx_base = find(class_labels_seen == baseNum);
        if isempty(idx_base)
            % Se la classe base non viene trovata, utilizza un fallback e assegna tutta la probabilità alla colonna di default
            disp('!!! Base non trovata, uso fallback');
            missingNum = str2double(predLabelChar);
            col_missing = class_idx_in_probs(missingNum+1);
            prob_matrix_test(i, col_missing) = 1;
            continue;
        end
        % Estrae la probabilità "raw" corrispondente alla classe base
        p_base = rawProbs(idx_base);
        % Imposta la colonna della classe mancante nel file (mappata come: 5->6, 7->8, 9->10)
        missingNum = numericPred;
        col_missing = missingNum + 1;
        
        % Prepara un nuovo vettore di probabilità partendo da rawProbs
        newProbs = rawProbs;
        % Azzera la probabilità della classe base, in modo da trasferirla alla classe mancante
        newProbs(idx_base) = 0;
        % Inizializza un vettore di probabilità a zero per tutte le 11 colonne (prob_0 ... prob_10)
        newProbsMtx = zeros(1,11);
        % Copia le probabilità delle classi "viste" nelle relative colonne della matrice di output
        for c = 1:length(class_labels_seen)
            out_col = class_idx_in_probs(c);
            newProbsMtx(out_col) = newProbs(c);
        end
        % Aggiunge la probabilità della classe base (p_base) nella colonna della classe mancante
        newProbsMtx(col_missing) = newProbsMtx(col_missing) + p_base;
        % Se la somma totale delle probabilità supera 1, normalizza il vettore
        ssum = sum(newProbsMtx);
        if ssum > 1
            newProbsMtx = newProbsMtx ./ ssum;
        end
        % Salva il vettore di probabilità finale per il campione corrente nella matrice di output
        prob_matrix_test(i,:) = newProbsMtx;
    end
end

% A questo punto, prob_matrix(i,:) ha 11 valori [prob_0..prob_10].
% Infine salviamo tutto su CSV
submission_final_test = [(1:numTest)', prob_matrix_test, confidence_binary_test];
submission_headers = ['sample_id', strcat('prob_', string(0:10)), 'confidence'];
submission_table_test = array2table(submission_final_test, 'VariableNames', submission_headers);
writetable(submission_table_test, 'submission_cnn_svm.csv');
fprintf('File submission_cnn_svm.csv generato con %d righe.\n', height(submission_table_test));

%% Generazione della submission per la validazione
numValidation = size(XValidation4D,4);
prob_matrix_val = zeros(numValidation, 11);
confidence_binary_val = zeros(numValidation,1);

for i = 1:numValidation
    rawProbs = YPredProbsVal(i,:);
    predLabelChar = char(YPredValidation(i));
    numericPred = str2double(predLabelChar);
    
    if max(rawProbs) > 0.7
        confidence_binary_val(i) = 1;
    else
        confidence_binary_val(i) = 0;
    end
    
    if ~ismember(predLabelChar, {'5','7','9'})
        idx_seen = find(class_labels_seen == numericPred);
        if isempty(idx_seen)
            prob_matrix_val(i,1) = 1;
        else
            col_out = class_idx_in_probs(idx_seen);
            prob_matrix_val(i, col_out) = 1;
        end
    else
        switch predLabelChar
            case '5', base = '4';
            case '7', base = '6';
            case '9', base = '8';
        end
        baseNum = str2double(base);
        idx_base = find(class_labels_seen == baseNum);
        if isempty(idx_base)
            disp('!!! Base non trovata, uso fallback');
            missingNum = str2double(predLabelChar);
            col_missing = class_idx_in_probs(missingNum+1);
            prob_matrix_val(i, col_missing) = 1;
            continue;
        end
        p_base = rawProbs(idx_base);
        missingNum = numericPred;
        col_missing = missingNum + 1;
        
        newProbs = rawProbs;
        newProbs(idx_base) = 0;
        newProbsMtx = zeros(1,11);
        for c = 1:length(class_labels_seen)
            out_col = class_idx_in_probs(c);
            newProbsMtx(out_col) = newProbs(c);
        end
        newProbsMtx(col_missing) = newProbsMtx(col_missing) + p_base;
        ssum = sum(newProbsMtx);
        if ssum > 1
            newProbsMtx = newProbsMtx ./ ssum;
        end
        prob_matrix_val(i,:) = newProbsMtx;
    end
end

% A questo punto, prob_matrix(i,:) ha 11 valori [prob_0..prob_10].
% Infine salviamo tutto su CSV
submission_final_val = [(1:numValidation)', prob_matrix_val, confidence_binary_val];
submission_table_val = array2table(submission_final_val, 'VariableNames', submission_headers);
writetable(submission_table_val, 'submission_validation.csv');
fprintf('File submission_validation.csv generato con %d righe.\n', height(submission_table_val));

%% Statistiche descrittive sulle probabilità massime
% Leggi i file CSV
testTable = readtable('submission_cnn_svm.csv');
valTable  = readtable('submission_validation.csv');

% Estrai le colonne di prob_0..prob_10 (assumendo siano le colonne 2..12)
probsTest = testTable{:, 2:12};
probsVal  = valTable{:, 2:12};

% Calcola la massima probabilità (in modo continuo) per ciascuna riga
maxProbTest = max(probsTest, [], 2);
maxProbVal  = max(probsVal, [], 2);

% Statistiche descrittive
meanTest = mean(maxProbTest);
medianTest = median(maxProbTest);
stdTest = std(maxProbTest);

meanVal = mean(maxProbVal);
medianVal = median(maxProbVal);
stdVal = std(maxProbVal);

fprintf('TEST - Media: %.3f, Mediana: %.3f, Std: %.3f\n', ...
    meanTest, medianTest, stdTest);
fprintf('VALIDATION - Media: %.3f, Mediana: %.3f, Std: %.3f\n', ...
    meanVal, medianVal, stdVal);

% Istogramma e stima di densità per il Test
figure;
subplot(1,2,1);
histogram(maxProbTest, 'Normalization','pdf');
hold on;
[xT, fT] = ksdensity(maxProbTest);
plot(xT, fT, 'LineWidth', 2);
title('Distribuzione Prob. Max - Test');
xlabel('Probabilità massima');
ylabel('Densità di probabilità');
legend('Istogramma','Stima densità');
hold off;

% Istogramma e stima di densità per la Validation
subplot(1,2,2);
histogram(maxProbVal, 'Normalization','pdf');
hold on;
[xV, fV] = ksdensity(maxProbVal);
plot(xV, fV, 'LineWidth', 2);
title('Distribuzione Prob. Max - Validation');
xlabel('Probabilità massima');
ylabel('Densità di probabilità');
legend('Istogramma','Stima densità');
hold off;