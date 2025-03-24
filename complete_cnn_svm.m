%% FaultSeverityEstimation_ImageInput_withAnomalyDetection.m
% Script per fault severity estimation trattando ogni segmento come "immagine"
% con dimensioni [20000 x 3 x 1]. I file txt contengono 4 colonne, si usano le prime 3 (X, Y, Z).
% Include anche un modulo di anomaly detection per la classe "2".

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
                    X_all = cat(3, X_all, segment); %#ok<AGROW>
                    y_all = [y_all; label]; %#ok<AGROW>
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
                X_all = cat(3, X_all, segment); %#ok<AGROW>
                fileInfo{end+1} = fileList(i).name; %#ok<AGROW>
            end
        end
    end
    X = X_all; % [segmentLength x 3 x numSegments]
end

%% Caricamento dati
fprintf('--- Inizio complete_cnn_svm.m ---\n');
fprintf('\n');
fprintf('--- Caricamento dati di training ---\n');
[XTrain, yTrain] = loadTrainingData(TRAIN_ROOT, SEGMENT_LENGTH, folderLabelMap);
fprintf('Dati training: %d segmenti di dimensione [%d x %d]\n', size(XTrain,3), size(XTrain,1), size(XTrain,2));

fprintf('--- Caricamento dati di test ---\n');
[XTest, testInfo] = loadTestData(TEST_ROOT, SEGMENT_LENGTH);
fprintf('Dati test (circa 3 per file): %d segmenti di dimensione [%d x %d]\n', size(XTest,3), size(XTest,1), size(XTest,2));

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
% Applica normalizzazione a training e test
for ch = 1:size(XTrain,2)
    XTrain(:,ch,:) = (XTrain(:,ch,:) - meanChannels(ch)) / stdChannels(ch);
    XTest(:,ch,:)  = (XTest(:,ch,:)  - meanChannels(ch)) / stdChannels(ch);
end

%% Conversione dei dati in formato 4D
% I dati di training, che attualmente hanno dimensioni [20000 x 3 x N], verranno convertiti
% in un array 4D di dimensioni [20000, 3, 1, N]
numTrain = size(XTrain,3);
XTrain4D = zeros(SEGMENT_LENGTH, 3, 1, numTrain);
for i = 1:numTrain
    XTrain4D(:,:,:,i) = XTrain(:,:,i);
end

numTest = size(XTest,3);
XTest4D = zeros(SEGMENT_LENGTH, 3, 1, numTest);
for i = 1:numTest
    XTest4D(:,:,:,i) = XTest(:,:,i);
end

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

% Estraiamo le feature per i dati di test dal layer 'relu_fc1'
featuresTest = activations(net, XTest4D, 'relu_fc1', 'OutputAs', 'rows');

% Soglia per il punteggio SVM (da regolare in base ai dati)
threshold = -0.1;

% Per ogni segmento del test, se la predizione è una classe base,
% controlla lo score dell'SVM e, se inferiore alla soglia, riassegna alla classe mancante.
for i = 1:numTest
    predLabel = char(YPredTest(i));  % Converte in char per compatibilità
    if ismember(predLabel, baseClasses)
        svmModel = svmModels(predLabel);
        [~, score] = predict(svmModel, featuresTest(i,:));
        if score < threshold
            newLabel = missingMap(predLabel);
            fprintf('Segmento %d (file: %s): Rilevata anomalia in classe %s (score=%.4f), riassegnata a %s.\n', ...
                i, testInfo{i}, predLabel, score, newLabel);
                YPredTest(i) = categorical({newLabel});
        end
    end
end

%% Esportazione dei risultati del test in submission.csv
% Creiamo una tabella che contiene il nome del file (o ID del segmento) e la predizione
%submissionTable = table(testInfo', string(YPredTest), confidences, ...
%    'VariableNames', {'File', 'Prediction', 'Confidence'});
%writetable(submissionTable, 'submission_cnn_svm.csv');
%fprintf('File submission_cnn_svm.csv generato con %d righe.\n', height(submissionTable));

%% (Opzionale) Esportazione dei risultati della validazione in validation_submission.csv
% Se vuoi avere una submission di validazione, usa i dati del validation set.
% Dato che per il validation set non hai "filename", puoi usare un ID numerico.
%YPredVal = classify(net, XVal);
%valIDs = (1:numel(YPredVal))';
%validationTable = table(valIDs, string(YPredVal), 'VariableNames', {'Id', 'Prediction'});
%writetable(validationTable, 'validation_submission_cnn_svm.csv');
%fprintf('File validation_submission_cnn_svm.csv generato con %d righe.\n', height(validationTable));

%% --- Creazione submission.csv in formato PHM Challenge ---

% Le classi "viste" nel training e il corrispondente indice di colonna (1-based) 
%  per prob_0 ... prob_10
% Vi sono 3 samples per file
class_labels_seen    = [0,1,2,3,4,6,8];  
class_idx_in_probs   = [1,2,3,4,5,7,9];  % Esempio: label 0 -> colonna 1, label 1->colonna2, ecc

% Le classi mancanti e la mappa tra classe base -> classe mancante
%  (4->5, 6->7, 8->9)
missingMap  = containers.Map({'4','6','8'},{'5','7','9'});

numTest     = size(XTest4D,4);
prob_matrix = zeros(numTest, 11);  % Perché vanno da prob_0 a prob_10
confidence_binary = zeros(numTest,1); 

for i = 1:numTest
    % Probabilità 'raw' dal tuo predict
    rawProbs = YPredProbs(i,:);   % ad es. dimensione [1 x 7]
    predLabelChar = char(YPredTest(i));  % '0','1','2','3','4','5','6','7','8','9' ...
    numericPred   = str2double(predLabelChar);

    % Calcolo confidence binaria (soglia a piacere, 0.7 come esempio)
    if max(rawProbs) > 0.7
        confidence_binary(i) = 1;
    else
        confidence_binary(i) = 0;
    end

    % CASO A: Classe predetta e' "vistA": 0,1,2,3,4,6,8
    % ---------------------------------------------------------------------
    if ~ismember(predLabelChar,{'5','7','9'})
        % Metto TUTTA la probabilita' = 1 sulla colonna corrispondente
        % e 0 sulle altre
        idx_seen = find(class_labels_seen == numericPred); 
        if isempty(idx_seen)
            % Caso improbabile: nel training set c'era la label, ma non la trovi...
            % fallback: metti tutto in prob_0
            prob_matrix(i,1) = 1; 
        else
            col_out = class_idx_in_probs(idx_seen); 
            prob_matrix(i, col_out) = 1;
        end

    % CASO B: Classe predetta e' "mancante": 5,7,9
    % ---------------------------------------------------------------------
    else
        % 1) Trovo la "base" da cui e' stata riassegnata
        %    Esempio: se label=5 => base=4
        base = '';  % '4','6','8'
        switch predLabelChar
            case '5'
                base = '4';
            case '7'
                base = '6';
            case '9'
                base = '8';
        end

        % 2) Trovo l'indice della base nei '7' canali e la corrispondente colonna nel file
        baseNum  = str2double(base);
        idx_base = find(class_labels_seen == baseNum);
        if isempty(idx_base)
            % fallback, se non trovi la base
            disp('!!! Non trovo la base. Metto la colonna mancante a 1');
            missingNum = str2double(predLabelChar);
            col_missing = class_idx_in_probs( missingNum+1 ); 
            prob_matrix(i,col_missing) = 1;
            continue;
        end
        
        % 3) La probabilita' "grezza" (della CNN) corrispondente a base
        p_base = rawProbs(idx_base);

        % 4) La colonna "mancante" nel file (5->colonna6, 7->colonna8, 9->colonna10)
        missingNum    = numericPred;    % 5,7,9
        col_missing   = missingNum + 1; %  5->6, 7->8, 9->10
        % se preferisci la logica class_idx_in_probs, puoi:
        %  col_missing = class_idx_in_probs( find([5,7,9]==missingNum ) );
        
        % 5) Travaso: settiamo p_missing = p_base
        %    e poi aggiungiamo le probabilita' delle altre classi cosi' come 
        %    date dalla rete, tranne la base che va a 0
        newProbs    = rawProbs;  
        newProbs(idx_base) = 0;   % Azzeri la base
        % Imposti la classe mancante con p_base
        newProbsMtx = zeros(1,11);  % prob_0..prob_10
        sum_before  = sum(newProbs);

        for c = 1:length(class_labels_seen)
            c_label = class_labels_seen(c);   % e.g. 0,1,2,3,4,6,8
            out_col = class_idx_in_probs(c);  % col da 1..11
            newProbsMtx(out_col) = newProbs(c);
        end

        % Aggiungo p_base su col_missing
        newProbsMtx(col_missing) = newProbsMtx(col_missing) + p_base;
        
        % (opzionale) Normalizzo se vuoi che la somma <= 1
        ssum = sum(newProbsMtx);
        if ssum>1
            newProbsMtx = newProbsMtx ./ ssum;  % oppure saturi a 1, come preferisci
        end

        % Copio nel prob_matrix
        prob_matrix(i,:) = newProbsMtx;
    end
end

% A questo punto, prob_matrix(i,:) ha 11 valori [prob_0..prob_10].
% Infine salviamo tutto su CSV
submission_final = [(1:numTest)', prob_matrix, confidence_binary];
submission_headers = ['sample_id', strcat('prob_', string(0:10)), 'confidence'];
submission_table = array2table(submission_final,'VariableNames',submission_headers);
writetable(submission_table, 'submission_cnn_svm.csv');
fprintf('File submission.csv generato con %d righe.\n',height(submission_table));