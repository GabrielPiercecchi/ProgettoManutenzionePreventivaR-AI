%% complete_pipeline_with_analysis.m
% Pipeline per anomaly detection e analisi delle condizioni operative
% con Autoencoder CNN unsupervised.
% 1) Carica e segmenta dati healthy (Pitting_degradation_level_0)
% 2) Addestra l'autoencoder CNN sui dati healthy
% 3) Carica e segmenta dati unhealthy (livelli 1..8)
% 4) Valuta l'errore di ricostruzione sui dati unhealthy e mappa in un livello
% 5) Aggrega l'errore a livello di file e analizza la relazione con i meta-dati V e N

clear; clc; close all;
fprintf("==== Inizio complete_pipeline_with_analysis.m ====\n");

%% =============================================================================
% STEP 1: CARICAMENTO DEI DATI HEALTHY E ESTRAZIONE FEATURE
%% =============================================================================
fprintf("\n[STEP 1] Caricamento dati HEALTHY (Pitting_degradation_level_0)...\n");
main_path = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\";

% Carica solo i file healthy (livello 0)
dataTable_healthy = load_data_by_level(main_path, "Pitting_degradation_level_0");
fprintf('Numero di file healthy caricati: %d\n', height(dataTable_healthy));

% Estrazione delle feature (dummy in questo esempio)
[feature_Table_healthy, data_feature_Table_healthy] = extract_features(dataTable_healthy);
fprintf("Feature extraction healthy completata.\n");

% Parametri di segmentazione
Fs = 20480;              
secPerSegment = 1;       
samplesPerSeg = Fs * secPerSegment;
overlap = 0;             
axisName = 'acc_x';      

fprintf("Segmentazione dei dati healthy...\n");
[XTrain, ~] = createSegmentsFromTable(dataTable_healthy, axisName, samplesPerSeg, overlap);
XTrain = reshape(XTrain, [samplesPerSeg, 1, 1, size(XTrain,3)]);
fprintf('Segmenti healthy totali: %d\n', size(XTrain,4));

%% =============================================================================
% STEP 2: ADDESTRAMENTO AUTOENCODER CNN SUI DATI HEALTHY
%% =============================================================================
fprintf("\n[STEP 2] Addestramento autoencoder CNN sui dati healthy...\n");
layers = [
    imageInputLayer([samplesPerSeg 1 1],"Name","input","Normalization","none")
    
    % ENCODER
    convolution2dLayer([3 1],16,"Padding","same","Name","conv_1")
    reluLayer("Name","relu_1")
    maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_1")
    
    convolution2dLayer([3 1],8,"Padding","same","Name","conv_2")
    reluLayer("Name","relu_2")
    maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_2")
    
    % DECODER
    transposedConv2dLayer([4 1],8,"Stride",[2 1],"Cropping","same","Name","transconv_1")
    reluLayer("Name","relu_3")
    
    transposedConv2dLayer([4 1],16,"Stride",[2 1],"Cropping","same","Name","transconv_2")
    reluLayer("Name","relu_4")
    
    convolution2dLayer([3 1],1,"Padding","same","Name","conv_3")
    regressionLayer("Name","regressionOutput")
    ];

miniBatchSize = 16;
maxEpochs = 5;  % Modifica a 30 o più per un training completo
options = trainingOptions("adam", ...
    "MaxEpochs", maxEpochs, ...
    "MiniBatchSize", miniBatchSize, ...
    "InitialLearnRate",1e-3, ...
    "Plots","training-progress", ...
    "Verbose",true);

net = trainNetwork(XTrain, XTrain, layers, options);
fprintf("Addestramento completato.\n");

% Calcolo errore di ricostruzione sui dati healthy per definire la soglia
XRecon_healthy = predict(net, XTrain);
reconstructionError_healthy = mean((XRecon_healthy - XTrain).^2, [1 2]);
reconstructionError_healthy = squeeze(reconstructionError_healthy);
figure;
histogram(reconstructionError_healthy, 50);
title('Errore di ricostruzione (Healthy)');
% Soglia: media + 3*std (questo parametro potrebbe essere tarato)
soglia = mean(reconstructionError_healthy) + 3*std(reconstructionError_healthy);
fprintf('Soglia di errore (healthy) = %.4f\n', soglia);

%% =============================================================================
% STEP 3: CARICAMENTO DEI DATI UNHEALTHY (livelli 1..8) E ESTRAZIONE FEATURE
%% =============================================================================
fprintf("\n[STEP 3] Caricamento dati UNHEALTHY (livelli 1..8)...\n");
dataTable_unhealthy = load_data_by_level(main_path, "Pitting_degradation_level_1", ...
    "Pitting_degradation_level_2", "Pitting_degradation_level_3", ...
    "Pitting_degradation_level_4", "Pitting_degradation_level_5", ...
    "Pitting_degradation_level_6", "Pitting_degradation_level_7", ...
    "Pitting_degradation_level_8");
fprintf('Numero di file unhealthy caricati: %d\n', height(dataTable_unhealthy));

% Estrazione delle feature unhealthy (dummy)
[feature_Table_unhealthy, data_feature_Table_unhealthy] = extract_features(dataTable_unhealthy);
fprintf("Feature extraction unhealthy completata.\n");

fprintf("Segmentazione dei dati unhealthy...\n");
% Catturiamo anche il numero di segmenti per file
[XUnhealthy, nSegPerFile] = createSegmentsFromTable(dataTable_unhealthy, axisName, samplesPerSeg, overlap);
XUnhealthy = reshape(XUnhealthy, [samplesPerSeg, 1, 1, size(XUnhealthy,3)]);
fprintf('Segmenti unhealthy totali: %d\n', size(XUnhealthy,4));

%% =============================================================================
% STEP 4: VALUTAZIONE SUI DATI UNHEALTHY E MAPPING IN LIVELLO
%% =============================================================================
fprintf("\n[STEP 4] Valutazione sui dati unhealthy...\n");
XRecon_unhealthy = predict(net, XUnhealthy);
reconstructionError_unhealthy = mean((XRecon_unhealthy - XUnhealthy).^2, [1 2]);
reconstructionError_unhealthy = squeeze(reconstructionError_unhealthy);
figure;
histogram(reconstructionError_unhealthy, 50);
hold on;
xline(soglia, 'r--', 'Threshold');
title('Errore di ricostruzione (Unhealthy)');

% Per ogni segmento unhealthy, mappa l'errore in un livello [0-10]
nSeg_unhealthy = numel(reconstructionError_unhealthy);
predictedLevels = zeros(nSeg_unhealthy,1);
probabilityMatrix = zeros(nSeg_unhealthy, 11);  % 11 colonne per livelli 0..10
confidenceVec = zeros(nSeg_unhealthy,1);

healthy_mean = mean(reconstructionError_healthy);
healthy_std  = std(reconstructionError_healthy);

fprintf("\n[STEP 4] Mapping dei segmenti unhealthy...\n");
for i = 1:nSeg_unhealthy
    err = reconstructionError_unhealthy(i);
    predictedLevels(i) = mapErrorToSeverity(err, soglia, healthy_std);
    probabilityMatrix(i,:) = levelToProbability(predictedLevels(i));
    confidenceVec(i) = computeConfidence(err, soglia, healthy_std);
end

% Ora, aggrega l'errore (e il livello) a livello di file:
nFiles_unhealthy = height(dataTable_unhealthy);
fileErrors = zeros(nFiles_unhealthy, 1);
indexStart = 1;
for i = 1:nFiles_unhealthy
    nSeg = nSegPerFile(i);
    if nSeg > 0
        fileErrors(i) = mean(reconstructionError_unhealthy(indexStart:indexStart+nSeg-1));
    else
        fileErrors(i) = NaN;
    end
    indexStart = indexStart + nSeg;
end

fprintf('Livello medio predetto (unhealthy) (per file): %.2f\n', mean(predictedLevels));
fprintf('Percentuale di segmenti con alta confidenza: %.2f%%\n', 100*mean(confidenceVec));

%% =============================================================================
% STEP 5: ANALISI DEI METADATI OPERATIVI
%% =============================================================================
fprintf("\n[STEP 5] Analisi delle condizioni operative...\n");
% Estrai i valori di velocità (V) e coppia (N) dal dataTable_unhealthy.
% Questi dovrebbero essere già stati estratti nella funzione datatable tramite extractMotorParams.
V_values = dataTable_unhealthy.motor_speed;  % Assumendo siano numerici
N_values = dataTable_unhealthy.torque;

% Scatter plot: errore medio per file vs velocità
figure;
scatter(V_values, fileErrors, 'filled');
xlabel('Motor Speed (V)');
ylabel('Media Errore di Ricostruzione (per file)');
title('Errore vs Motor Speed (Unhealthy)');

% Scatter plot: errore medio per file vs coppia
figure;
scatter(N_values, fileErrors, 'filled');
xlabel('Torque (N)');
ylabel('Media Errore di Ricostruzione (per file)');
title('Errore vs Torque (Unhealthy)');

% Scatter 3D: errore vs V e N
figure;
scatter3(V_values, N_values, fileErrors, 'filled');
xlabel('Motor Speed (V)');
ylabel('Torque (N)');
zlabel('Media Errore di Ricostruzione');
title('Errore vs V e N (Unhealthy)');

%% =============================================================================
% STEP 6: CREAZIONE DELLA SUBMISSION
%% =============================================================================
fprintf("\n[STEP 6] Creazione file di submission...\n");
% Creiamo la submission a livello di segmento (un rigo per ogni segmento unhealthy)
% Il file avrà 13 colonne: [sample_id, prob_0, ..., prob_10, confidence]
sample_ids = (1:nSeg_unhealthy)';
submission = [sample_ids, probabilityMatrix, confidenceVec];
csvwrite('submission.csv', submission);
fprintf("Submission salvata in submission.csv\n");

fprintf("\n==== Fine complete_pipeline_with_analysis.m ====\n");

%% =============================================================================
% FUNZIONI LOCALI
%% =============================================================================

function level = mapErrorToSeverity(error, soglia, healthy_std)
    % Mappa l'errore di ricostruzione in un livello di degradazione da 0 a 10.
    % Se l'errore è inferiore o uguale alla soglia, il livello è 0.
    % Altrimenti, ogni healthy_std in eccesso aumenta il livello di 1, saturando a 10.
    if error <= soglia
        level = 0;
    else
        level = min(10, (error - soglia) / healthy_std);
    end
end

function probVec = levelToProbability(level)
    % Converte il livello (reale, da 0 a 10) in una distribuzione di probabilità
    % usando una funzione gaussiana centrata sul livello.
    x = 0:10;
    sigma = 1;  % Parametro da tarare in base ai dati
    probVec = exp(-((x - level).^2) / (2*sigma^2));
    probVec = probVec / sum(probVec);
end

function conf = computeConfidence(error, soglia, healthy_std)
    % Assegna una confidenza binaria in base all'errore.
    % Ad esempio, se l'errore è inferiore a soglia + 2*healthy_std, confidenza = 1, altrimenti 0.
    if error <= (soglia + 2*healthy_std)
        conf = 1;
    else
        conf = 0;
    end
end

function dataTable = load_data_by_level(main_path, varargin)
    fprintf("  [load_data_by_level] Caricamento file .txt...\n");
    filelist = dir(fullfile(main_path, '**', '*.txt'));
    data_cell = {};
    for k = 1:numel(filelist)
        folderK = filelist(k).folder;
        isLevelMatch = false;
        for v = 1:numel(varargin)
            if contains(folderK, varargin{v})
                isLevelMatch = true;
                break;
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
    Fs = 20480; % sample rate
    dataTable = datatable(data_cell, Fs);
end

function [X, nSegmentsPerFile] = createSegmentsFromTable(dataTable, axisName, segLength, overlap)
    nFiles = height(dataTable);
    XCell = cell(nFiles,1);
    nSegmentsPerFile = zeros(nFiles,1);
    fprintf("  [createSegmentsFromTable] Inizio estrazione segmenti...\n");
    for i = 1:nFiles
        tt = dataTable.(axisName){i};  % timetable
        if isempty(tt)
            continue;
        end
        x = tt.Variables;
        segments = segmentSignal(x, segLength, overlap);
        segments3D = reshape(segments, segLength, 1, []);
        XCell{i} = segments3D;
        nSegmentsPerFile(i) = size(segments3D,3);
    end
    X = cat(3, XCell{:});
    fprintf("  [createSegmentsFromTable] Segmenti totali estratti: %d\n", size(X,3));
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