%% complete_autoencoder_pipeline.m
% Pipeline per anomaly detection e stima del fault level (0-10)
% con autoencoder CNN unsupervised ed estrazione dummy delle feature.
%
% Il flusso:
%   STEP 0: Nel file txt_sample_transformer.m vengono limitiati i campionamenti a 3 secondi per tutte le velocità.
%   STEP 1: Caricamento dati HEALTHY (Pitting_degradation_level_0),
%           estrazione delle feature e segmentazione.
%   STEP 2: Addestramento dell'autoencoder CNN sui dati healthy.
%   STEP 3: Caricamento dati UNHEALTHY (livelli 1..8),
%           estrazione delle feature e segmentazione.
%   STEP 4: Calcolo dell'errore di ricostruzione sui dati unhealthy,
%           mapping in un livello di degradazione (0-10),
%           generazione della distribuzione di probabilità e calcolo della confidenza.
%   STEP 5: Analisi dei meta-dati operativi (Motor Speed e Torque) su unhealthy.
%   STEP 6: Creazione file CSV di submission per i dati unhealthy.
%   STEP 7: Caricamento dati TEST (dalla cartella di test),
%           segmentazione, mapping e creazione file CSV di submission_test.
%   STEP 8: Caricamento dati VALIDATION, segmentazione, mapping e creazione file CSV di submission_validation.
%   STEP 9: Tuning & Analisi: Visualizzazione di threshold alternativi e statistiche.
%   STEP 10: Creazione file per il Diagnostic Feature Designer.
%
% NOTA: I parametri (soglia, healthy_std, sigma) sono esemplificativi
%       colNames = {'sample_id','prob_0','prob_1','prob_2','prob_3','prob_4','prob_5','prob_6','prob_7','prob_8','prob_9','prob_10','confidence'};
%

clear; clc; close all;
fprintf("==== Inizio complete_autoencoder_pipeline.m ====\n");

%% =============================================================================
% STEP 1: CARICAMENTO DEI DATI HEALTHY (LIVELLO 0)
%% =============================================================================
fprintf("\n[STEP 1] Caricamento dati HEALTHY (Pitting_degradation_level_0)...\n");
main_path_train = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\";

% Carica solo i file healthy (livello 0)
dataTable_healthy = load_data_by_level(main_path_train, "Pitting_degradation_level_0");
fprintf('Numero di file healthy caricati: %d\n', height(dataTable_healthy));

% Estrazione delle feature (dummy: restituisce i dati in ingresso)
[feature_Table_healthy, data_feature_Table_healthy] = extract_features(dataTable_healthy);
fprintf("Feature extraction (healthy) completata.\n");

% Parametri di segmentazione
Fs = 20480;                         % Sample rate   
secPerSegment = 3;                  % Lunghezza del segmento in secondi
samplesPerSeg = Fs * secPerSegment;   % Lunghezza del segmento in campioni
overlap = 0;                        % Sovrapposizione tra segmenti       
axisNames = {'acc_x','acc_y','acc_z', 'tachometer'};  % Utilizza tutti e tre gli assi più il tachimetro

fprintf("Segmentazione dei dati healthy...\n");
[XTrain, ~] = createSegmentsFromTableMulti(dataTable_healthy, axisNames, samplesPerSeg, overlap);
% La funzione createSegmentsFromTableMulti dovrebbe restituire XTrain con dimensioni:
% [samplesPerSeg x 1 x numChannels x nSegments]
numChannels = length(axisNames);
XTrain = reshape(XTrain, [samplesPerSeg, numChannels, 1, size(XTrain,4)]);
fprintf('Segmenti healthy totali: %d\n', size(XTrain,4));

%% =============================================================================
% STEP 2: ADDESTRAMENTO AUTOENCODER CNN SU HEALTHY
%% =============================================================================
fprintf("\n[STEP 2] Addestramento autoencoder CNN sui dati healthy...\n");
layers = [
    imageInputLayer([samplesPerSeg, numChannels, 1],"Name","input","Normalization","none")
    % Encoder
    convolution2dLayer([3 1],16,"Padding","same","Name","conv_1")
    reluLayer("Name","relu_1")
    maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_1")
    convolution2dLayer([3 1],8,"Padding","same","Name","conv_2")
    reluLayer("Name","relu_2")
    maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_2")
    % Decoder
    transposedConv2dLayer([4 1],8,"Stride",[2 1],"Cropping","same","Name","transconv_1")
    reluLayer("Name","relu_3")
    transposedConv2dLayer([4 1],16,"Stride",[2 1],"Cropping","same","Name","transconv_2")
    reluLayer("Name","relu_4")
    convolution2dLayer([3 1],1,"Padding","same","Name","conv_3")
    regressionLayer("Name","regressionOutput")
    ];

miniBatchSize = 16;
maxEpochs = 10;  % Esempio: aumenta il numero di epoche per un addestramento più lungo
options = trainingOptions("adam", ...
    "MaxEpochs", maxEpochs, ...
    "MiniBatchSize", miniBatchSize, ...
    "InitialLearnRate",1e-3, ...
    "Plots","training-progress", ...
    "Verbose",true);

net = trainNetwork(XTrain, XTrain, layers, options);
fprintf("Addestramento completato.\n");

% Calcola errore di ricostruzione sui dati healthy per definire la soglia
XRecon_healthy = predict(net, XTrain);
reconstructionError_healthy = mean((XRecon_healthy - XTrain).^2, [1 2]);
reconstructionError_healthy = squeeze(reconstructionError_healthy);
figure;
histogram(reconstructionError_healthy, 50);
title('Errore di ricostruzione (Healthy)');

% Imposta la soglia (esempio: media + 3*std)
soglia = mean(reconstructionError_healthy) + 3*std(reconstructionError_healthy);
fprintf('Soglia di errore (healthy) = %.4f\n', soglia);

%% =============================================================================
% STEP 3: CARICAMENTO DEI DATI UNHEALTHY (LIVELLI 1..8)
%% =============================================================================
fprintf("\n[STEP 3] Caricamento dati UNHEALTHY (livelli 1..8)...\n");
dataTable_unhealthy = load_data_by_level(main_path_train, "Pitting_degradation_level_1", ...
    "Pitting_degradation_level_2", "Pitting_degradation_level_3", ...
    "Pitting_degradation_level_4", ...
    "Pitting_degradation_level_6", ...
    "Pitting_degradation_level_8");
fprintf('Numero di file unhealthy caricati: %d\n', height(dataTable_unhealthy));

% Estrazione delle feature unhealthy (dummy)
[feature_Table_unhealthy, data_feature_Table_unhealthy] = extract_features(dataTable_unhealthy);
fprintf("Feature extraction (unhealthy) completata.\n");

fprintf("Segmentazione dei dati unhealthy...\n");
[XUnhealthy, nSegPerFile_unhealthy] = createSegmentsFromTableMulti(dataTable_unhealthy, axisNames, samplesPerSeg, overlap);
numChannels = length(axisNames);
XUnhealthy = reshape(XUnhealthy, [samplesPerSeg, numChannels, 1, size(XUnhealthy,4)]);
fprintf('Segmenti unhealthy totali: %d\n', size(XUnhealthy,4));

%% =============================================================================
% STEP 4: VALUTAZIONE DEI DATI UNHEALTHY E MAPPING IN LIVELLO
%% =============================================================================
fprintf("\n[STEP 4] Valutazione su dati unhealthy...\n");
XRecon_unhealthy = predict(net, XUnhealthy);
reconstructionError_unhealthy = mean((XRecon_unhealthy - XUnhealthy).^2, [1 2]);
reconstructionError_unhealthy = squeeze(reconstructionError_unhealthy);
figure;
histogram(reconstructionError_unhealthy, 50);
hold on;
xline(soglia, 'r--', 'Threshold');
title('Errore di ricostruzione (Unhealthy)');

nSeg_unhealthy = numel(reconstructionError_unhealthy);
predictedLevels_unhealthy = zeros(nSeg_unhealthy,1);
	probMatrix_unhealthy = zeros(nSeg_unhealthy, 11);
	confVec_unhealthy = zeros(nSeg_unhealthy,1);

healthy_mean = mean(reconstructionError_healthy);
healthy_std  = std(reconstructionError_healthy);

fprintf("\n[STEP 4] Mapping dei segmenti unhealthy...\n");
for i = 1:nSeg_unhealthy
    err = reconstructionError_unhealthy(i);
    predictedLevels_unhealthy(i) = mapErrorToSeverity(err, soglia, healthy_std);
    probMatrix_unhealthy(i,:) = levelToProbability(predictedLevels_unhealthy(i));
    confVec_unhealthy(i) = computeConfidence(err, soglia, healthy_std);
end

fprintf('Livello medio predetto (unhealthy): %.2f\n', mean(predictedLevels_unhealthy));
fprintf('Percentuale di segmenti con alta confidenza: %.2f%%\n', 100*mean(confVec_unhealthy));

% Aggrega l'errore a livello di file
nFiles_unhealthy = height(dataTable_unhealthy);
fileErrors_unhealthy = zeros(nFiles_unhealthy, 1);
	idxStart = 1;
for f = 1:nFiles_unhealthy
    nSegF = nSegPerFile_unhealthy(f);
    if nSegF > 0
        fileErrors_unhealthy(f) = mean(reconstructionError_unhealthy(idxStart:idxStart+nSegF-1));
    else
        fileErrors_unhealthy(f) = NaN;
    end
    idxStart = idxStart + nSegF;
end

%% =============================================================================
% STEP 5: ANALISI DEI METADATI OPERATIVI (Motor Speed e Torque) SU UNHEALTHY
%% =============================================================================
fprintf("\n[STEP 5] Analisi dei meta-dati (Motor Speed, Torque) sui dati unhealthy...\n");
V_values_unhealthy = dataTable_unhealthy.motor_speed;  % Motor Speed
N_values_unhealthy = dataTable_unhealthy.torque;         % Torque

figure;
scatter(V_values_unhealthy, fileErrors_unhealthy, 'filled');
xlabel('Motor Speed (V)');
ylabel('Errore medio di ricostruzione (per file)');
title('Errore vs Motor Speed (Unhealthy)');

figure;
scatter(N_values_unhealthy, fileErrors_unhealthy, 'filled');
xlabel('Torque (N)');
ylabel('Errore medio di ricostruzione (per file)');
title('Errore vs Torque (Unhealthy)');

figure;
scatter3(V_values_unhealthy, N_values_unhealthy, fileErrors_unhealthy, 'filled');
xlabel('Motor Speed (V)');
ylabel('Torque (N)');
zlabel('Errore medio');
title('Errore vs V e N (Unhealthy)');

%% =============================================================================
% STEP 6: CREAZIONE FILE DI SUBMISSION PER I DATI UNHEALTHY
%% =============================================================================
fprintf("\n[STEP 6] Creazione file di submission (Unhealthy)...\n");
colNames = {'sample_id','prob_0','prob_1','prob_2','prob_3','prob_4','prob_5','prob_6','prob_7','prob_8','prob_9','prob_10','confidence'};
sample_ids_unhealthy = (1:nSeg_unhealthy)';
submission_unhealthy = [sample_ids_unhealthy, probMatrix_unhealthy, confVec_unhealthy];
T_sub_unhealthy = array2table(submission_unhealthy, 'VariableNames', colNames);
writetable(T_sub_unhealthy, 'submission_unhealthy.csv');
fprintf("File submission_unhealthy.csv creato.\n");

%% =============================================================================
% STEP 7: CARICAMENTO DATI DI TEST E GENERAZIONE SUBMISSION_TEST
%% =============================================================================
fprintf("\n[STEP 7] Caricamento dati TEST...\n");
main_path_test = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_test_data\";
% Carica TUTTI i file .txt nella cartella di test
dataTable_test = load_data_by_level(main_path_test);
fprintf('Numero di file test caricati: %d\n', height(dataTable_test));

fprintf("Segmentazione dei dati test...\n");
[XTest, nSegPerFile_test] = createSegmentsFromTableMulti(dataTable_test, axisNames, samplesPerSeg, overlap);
% Imposta XTest con dimensioni [segLength x numChannels x 1 x nSegments]
XTest = reshape(XTest, [samplesPerSeg, numChannels, 1, size(XTest,4)]);
fprintf('Segmenti test totali: %d\n', size(XTest,4));

fprintf("\n[STEP 7] Predizione e mapping sui dati test...\n");
XRecon_test = predict(net, XTest);
reconstructionError_test = mean((XRecon_test - XTest).^2, [1 2]);
reconstructionError_test = squeeze(reconstructionError_test);

figure;
histogram(reconstructionError_test, 50);
hold on;
xline(soglia, 'r--', 'Threshold');
title('Errore di ricostruzione (Test)');

nSeg_test = numel(reconstructionError_test);
predictedLevels_test = zeros(nSeg_test,1);
	probMatrix_test = zeros(nSeg_test, 11);
	confVec_test = zeros(nSeg_test,1);

for i = 1:nSeg_test
    err = reconstructionError_test(i);
    predictedLevels_test(i) = mapErrorToSeverity(err, soglia, healthy_std);
    probMatrix_test(i,:) = levelToProbability(predictedLevels_test(i));
    confVec_test(i) = computeConfidence(err, soglia, healthy_std);
end

fprintf("Livello medio predetto (test): %.2f\n", mean(predictedLevels_test));
fprintf("Percentuale di segmenti test con alta confidenza: %.2f%%\n", 100*mean(confVec_test));

fprintf("\n[STEP 7] Creazione file di submission per dati test...\n");
colNames = {'sample_id','prob_0','prob_1','prob_2','prob_3','prob_4','prob_5','prob_6','prob_7','prob_8','prob_9','prob_10','confidence'};
sample_ids_test = (1:nSeg_test)';
submission_test = [sample_ids_test, probMatrix_test, confVec_test];
T_sub_test = array2table(submission_test, 'VariableNames', colNames);
writetable(T_sub_test, 'submission_cnn.csv');
fprintf("File submission_cnn.csv creato.\n");

%% =============================================================================
% STEP 8: CARICAMENTO DATI VALIDATION ED ELABORAZIONE (CREAZIONE CSV)
%% =============================================================================
%fprintf("\n[STEP 8] Caricamento dati VALIDATION...\n");
%main_path_val = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_validation_data\";
%dataTable_val = load_data_by_level(main_path_val);
%fprintf('Numero di file validation caricati: %d\n', height(dataTable_val));

%fprintf("Segmentazione dei dati validation...\n");
%[XVal, nSegPerFile_val] = createSegmentsFromTableMulti(dataTable_val, axisNames, samplesPerSeg, overlap);
%numChannels = length(axisNames);
%XVal = reshape(XVal, [samplesPerSeg, numChannels, 1, size(XVal,4)]);
%fprintf('Segmenti validation totali: %d\n', size(XVal,4));

%fprintf("\n[STEP 8] Elaborazione dati validation e creazione file CSV...\n");
%XRecon_val = predict(net, XVal);
%reconstructionError_val = mean((XRecon_val - XVal).^2, [1 2]);
%reconstructionError_val = squeeze(reconstructionError_val);

%Seg_val = numel(reconstructionError_val);
%predictedLevels_val = zeros(nSeg_val,1);
%probMatrix_val = zeros(nSeg_val, 11);
%confVec_val = zeros(nSeg_val,1);
%for i = 1:nSeg_val
%    err = reconstructionError_val(i);
%    predictedLevels_val(i) = mapErrorToSeverity(err, soglia, healthy_std);
%    probMatrix_val(i,:) = levelToProbability(predictedLevels_val(i));
%    confVec_val(i) = computeConfidence(err, soglia, healthy_std);
%end

%fprintf("Livello medio predetto (validation): %.2f\n", mean(predictedLevels_val));
%fprintf("Percentuale di segmenti validation con alta confidenza: %.2f%%\n", 100*mean(confVec_val));

%sample_ids_val = (1:nSeg_val)';
%submission_val = [sample_ids_val, probMatrix_val, confVec_val];
% Creazione tabella con header per submission_validation
%colNames = {'sample_id','prob_0','prob_1','prob_2','prob_3','prob_4','prob_5','prob_6','prob_7','prob_8','prob_9','prob_10','confidence'};
%T_sub_val = array2table(submission_val, 'VariableNames', colNames);
%writetable(T_sub_val, 'submission_validation.csv');
%fprintf("File submission_validation_cnn.csv creato.\n");

%% =============================================================================
% STEP 9: Tuning & Analisi: Visualizzazione di threshold alternativi e statistiche
%% =============================================================================
fprintf("\n[STEP 9] Tuning & Analisi: Visualizzazione di threshold alternativi e statistiche...\n");

% Calcola soglie alternative basate sui dati healthy
soglia2 = mean(reconstructionError_healthy) + 2*std(reconstructionError_healthy);
soglia4 = mean(reconstructionError_healthy) + 4*std(reconstructionError_healthy);

% Visualizza l'istogramma degli errori healthy con le soglie alternative
figure;
histogram(reconstructionError_healthy, 50);
hold on;
xline(soglia, 'r--', 'Soglia (3*std)');
xline(soglia2, 'g--', 'Soglia (2*std)');
xline(soglia4, 'b--', 'Soglia (4*std)');
title('Analisi errori healthy e threshold alternativi');
xlabel('Errore di ricostruzione');
ylabel('Frequenza');
legend('Errori healthy','Soglia 3*std','Soglia 2*std','Soglia 4*std');

% Stampa statistiche chiave
fprintf('Media errore healthy: %.4f\n', mean(reconstructionError_healthy));
fprintf('Std errore healthy: %.4f\n', std(reconstructionError_healthy));
fprintf('Soglia (media + 3*std): %.4f\n', soglia);
fprintf('Soglia alternativa (media + 2*std): %.4f\n', soglia2);
fprintf('Soglia alternativa (media + 4*std): %.4f\n', soglia4);

%% =============================================================================
% STEP 10: CREAZIONE FILE PER IL DIAGNOSTIC FEATURE DESIGNER
%% =============================================================================
fprintf("\n[STEP 10] Creazione file per il Diagnostic Feature Designer...\n");
% Combina le tabelle delle feature dai dati healthy e unhealthy.
% (Se preferisci usare solo i dati healthy, sostituisci 'data_feature_Table_unhealthy'
% con una tabella vuota o ometti questa parte.)
diagnosticFeatureTable = [data_feature_Table_healthy; data_feature_Table_unhealthy];

% Salva la tabella in un file MAT che può essere caricato in Diagnostic Feature Designer
save('diagnosticFeatureTable.mat', 'diagnosticFeatureTable', '-v7.3');
fprintf("File diagnosticFeatureData.mat creato per il Diagnostic Feature Designer.\n");

fprintf("\n==== Fine complete_pipeline_with_analysis.m ====\n");

%% ======================== FUNZIONI LOCALI ========================

function [X, nSegmentsPerFile] = createSegmentsFromTableMulti(dataTable, axisNames, segLength, overlap)
    % createSegmentsFromTableMulti - Estrae segmenti da più canali per ciascun file
    % e garantisce che ogni file abbia lo stesso numero di segmenti per tutti i canali.
    %
    % INPUT:
    %   dataTable  - Tabella contenente i dati, con campi per ciascun canale (es. acc_x, acc_y, acc_z)
    %   axisNames  - Cell array con i nomi degli assi da utilizzare (es. {'acc_x','acc_y','acc_z'})
    %   segLength  - Lunghezza del segmento in campioni
    %   overlap    - Numero di campioni di sovrapposizione tra segmenti
    %
    % OUTPUT:
    %   X               - Array 4D di segmenti con dimensioni:
    %                     [segLength x numChannels x 1 x totalSegments]
    %   nSegmentsPerFile- Vettore con il numero di segmenti estratti per ciascun file
    
    nFiles = height(dataTable);
    XCell = cell(nFiles, 1);
    nSegmentsPerFile = zeros(nFiles, 1);
    fprintf("  [createSegmentsFromTableMulti] Inizio estrazione segmenti...\n");

    for i = 1:nFiles
        nChannels = length(axisNames);
        segmentsForFile = cell(nChannels, 1);
        nSegs = zeros(nChannels, 1);
        
        % Estrai i segmenti per ciascun canale
        for j = 1:nChannels
            tt = dataTable.(axisNames{j}){i};
            if isempty(tt)
                segmentsForFile{j} = [];
                nSegs(j) = 0;
            else
                x = tt.Variables;
                segs = segmentSignal(x, segLength, overlap);  % [segLength x nSeg]
                segmentsForFile{j} = segs;
                nSegs(j) = size(segs, 2);
            end
        end
        
        % Trova il numero minimo di segmenti tra i canali per il file corrente
        minSeg = min(nSegs);
        if minSeg == 0
            % Se per almeno un canale non ci sono segmenti, escludi il file
            XCell{i} = [];
            nSegmentsPerFile(i) = 0;
        else
            % Prealloca per i segmenti: [segLength x minSeg x nChannels]
            fileSegments = zeros(segLength, minSeg, nChannels);
            for j = 1:nChannels
                fileSegments(:, :, j) = segmentsForFile{j}(:, 1:minSeg);
            end
            % Risistema le dimensioni in modo da ottenere [segLength x numChannels x 1 x minSeg]
            fileSegments = permute(fileSegments, [1 3 2]);
            fileSegments = reshape(fileSegments, [segLength, nChannels, 1, minSeg]);
            XCell{i} = fileSegments;
            nSegmentsPerFile(i) = minSeg;
        end
    end
    
    % Rimuovi eventuali celle vuote e concatena lungo la quarta dimensione
    XValid = XCell(~cellfun('isempty', XCell));
    if isempty(XValid)
        X = [];
    else
        X = cat(4, XValid{:});
    end
    fprintf("  [createSegmentsFromTableMulti] Segmenti totali estratti: %d\n", size(X,4));
end

function level = mapErrorToSeverity(error, soglia, healthy_std)
    % Mappa l'errore di ricostruzione in un livello di degradazione da 0 a 10.
    if error <= soglia
        level = 0;
    else
        level = min(10, (error - soglia) / healthy_std);
    end
end

function probVec = levelToProbability(level)
    % Converte il livello (0-10) in una distribuzione di probabilità usando una gaussiana.
    x = 0:10;
    sigma = 1;  % Parametro esemplificativo: taralo in base ai dati
    probVec = exp(-((x - level).^2) / (2*sigma^2));
    probVec = probVec / sum(probVec);
end

function conf = computeConfidence(error, soglia, healthy_std)
    % Assegna una confidenza binaria: 1 se l'errore è <= soglia+2*healthy_std, altrimenti 0.
    if error <= (soglia + 2*healthy_std)
        conf = 1;
    else
        conf = 0;
    end
end

function dataTable = load_data_by_level(main_path, varargin)
    % Se non viene passato alcun filtro, carica TUTTI i file .txt nella cartella.
    if nargin < 2 || isempty(varargin)
        filterLevels = {};
    else
        filterLevels = varargin;
    end
    fprintf("  [load_data_by_level] Caricamento file .txt...\n");
    filelist = dir(fullfile(main_path, '**', '*.txt'));
    data_cell = {};
    for k = 1:numel(filelist)
        folderK = filelist(k).folder;
        if isempty(filterLevels)
            isLevelMatch = true;
        else
            isLevelMatch = false;
            for v = 1:numel(filterLevels)
                if contains(folderK, filterLevels{v})
                    isLevelMatch = true;
                    break;
                end
            end
        end
        if ~isLevelMatch
            continue;
        end
        full_filename = fullfile(filelist(k).folder, filelist(k).name);
        data = readmatrix(full_filename, 'Delimiter',' ');
        [~, nCols] = size(data);
        if nCols < 4
            warning('Il file %s ha meno di 4 colonne. Saltato.', full_filename);
            continue;
        end
        data_struct.data = data;
        data_struct.name = full_filename;
        data_cell{end+1} = data_struct;
    end
    fprintf("  [load_data_by_level] File filtrati: %d\n", numel(data_cell));
    Fs = 20480; % Sample rate
    dataTable = datatable(data_cell, Fs);
end

function segments = segmentSignal(x, segLength, overlap)
    L = length(x);
    step = segLength - overlap;
    idxStart = 1:step:(L - segLength + 1);
    nSeg = numel(idxStart);
    segments = zeros(segLength, nSeg);
    for k = 1:nSeg
        idx = idxStart(k):(idxStart(k)+segLength-1);
        segments(:,k) = x(idx);
    end
end

function [feature_Table, data_feature_Table] = extract_features(dataTable)
    % Funzione dummy per l'estrazione delle feature.
    % In questo esempio restituisce semplicemente i dati in ingresso.
    feature_Table = dataTable;
    data_feature_Table = dataTable;
end