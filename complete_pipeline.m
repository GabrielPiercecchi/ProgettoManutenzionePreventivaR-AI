%% complete_pipeline.m
% Esempio "passo-passo" per anomaly detection con Autoencoder CNN 1D.
% 1) Carica e segmenta dati healthy (livello 0)
% 2) Addestra l'autoencoder
% 3) Carica e segmenta dati unhealthy (livelli 1..8)
% 4) Valuta l'errore di ricostruzione e confronta con soglia

%% =============================================================================
% STEP 1: CARICAMENTO DEI DATI HEALTHY
% =============================================================================
clear; clc; close all;

% Imposta il percorso principale
main_path = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\";

% Carica solo i file di Pitting_degradation_level_0
dataTable_healthy = load_data_by_level(main_path, "Pitting_degradation_level_0");
fprintf('\nNumero di file (healthy) caricati: %d\n', height(dataTable_healthy));

% Parametri di segmentazione
Fs = 20480;              % Frequenza di campionamento
secPerSegment = 1;       % Finestra di 1 secondo
samplesPerSeg = Fs*secPerSegment;
overlap = 0;             % Nessun overlap
axisName = 'acc_x';      % Scegli l'asse su cui addestrare (acc_x, acc_y, acc_z, ...)

% Segmenta i dati healthy
[XTrain, ~] = createSegmentsFromTable(dataTable_healthy, axisName, samplesPerSeg, overlap);
% Reshape in 4D per trainNetwork: [samplesPerSeg x 1 x 1 x nSegments]
XTrain = reshape(XTrain, [samplesPerSeg, 1, 1, size(XTrain,3)]);

fprintf('Segmenti healthy totali: %d\n', size(XTrain,4));

%% =============================================================================
% STEP 2: ADDESTRAMENTO AUTOENCODER CNN
% =============================================================================
% Definizione dell'architettura CNN 1D (usando layer 2D con dimensione 1)
layers = [
    imageInputLayer([samplesPerSeg 1 1],"Name","input","Normalization","none")

    % --- ENCODER ---
    convolution2dLayer([3 1],16,"Padding","same","Name","conv_1")
    reluLayer("Name","relu_1")
    maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_1")

    convolution2dLayer([3 1],8,"Padding","same","Name","conv_2")
    reluLayer("Name","relu_2")
    maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_2")

    % --- DECODER ---
    transposedConv2dLayer([4 1],8,"Stride",[2 1],"Cropping","same","Name","transconv_1")
    reluLayer("Name","relu_3")

    transposedConv2dLayer([4 1],16,"Stride",[2 1],"Cropping","same","Name","transconv_2")
    reluLayer("Name","relu_4")

    convolution2dLayer([3 1],1,"Padding","same","Name","conv_3")

    regressionLayer("Name","regressionOutput")];

% Opzioni di training
miniBatchSize = 16;
maxEpochs = 5;  % Aumenta a 30 o più se vuoi un training più esteso
options = trainingOptions("adam", ...
    "MaxEpochs", maxEpochs, ...
    "MiniBatchSize", miniBatchSize, ...
    "InitialLearnRate",1e-3, ...
    "Plots","training-progress", ...
    "Verbose",true);

% Addestramento (input = output per l'autoencoder)
net = trainNetwork(XTrain, XTrain, layers, options);

% Calcolo errore di ricostruzione sui dati healthy
XRecon_healthy = predict(net, XTrain);
reconstructionError_healthy = mean((XRecon_healthy - XTrain).^2, [1 2]);
reconstructionError_healthy = squeeze(reconstructionError_healthy);

% Istogramma dell'errore healthy
figure;
histogram(reconstructionError_healthy, 50);
title('Distribuzione errore di ricostruzione (Healthy)');

% Definisci soglia (es. media + 3*std)
soglia = mean(reconstructionError_healthy) + 3*std(reconstructionError_healthy);
fprintf('Soglia di errore (healthy) = %.4f\n', soglia);

%% =============================================================================
% STEP 3: CARICAMENTO DEI DATI UNHEALTHY
% =============================================================================
% Carichiamo ora i dati dai livelli di pitting 1..8
dataTable_unhealthy = load_data_by_level(main_path, "Pitting_degradation_level_1", ...
    "Pitting_degradation_level_2", ...
    "Pitting_degradation_level_3", ...
    "Pitting_degradation_level_4", ...
    "Pitting_degradation_level_5", ...
    "Pitting_degradation_level_6", ...
    "Pitting_degradation_level_7", ...
    "Pitting_degradation_level_8");

fprintf('\nNumero di file (unhealthy) caricati: %d\n', height(dataTable_unhealthy));

% Segmentazione dati unhealthy
[XUnhealthy, ~] = createSegmentsFromTable(dataTable_unhealthy, axisName, samplesPerSeg, overlap);
XUnhealthy = reshape(XUnhealthy, [samplesPerSeg, 1, 1, size(XUnhealthy,3)]);
fprintf('Segmenti unhealthy totali: %d\n', size(XUnhealthy,4));

%% =============================================================================
% STEP 4: VALUTAZIONE SUI DATI UNHEALTHY
% =============================================================================
XRecon_unhealthy = predict(net, XUnhealthy);
reconstructionError_unhealthy = mean((XRecon_unhealthy - XUnhealthy).^2, [1 2]);
reconstructionError_unhealthy = squeeze(reconstructionError_unhealthy);

% Istogramma errore di ricostruzione (unhealthy)
figure;
histogram(reconstructionError_unhealthy, 50);
hold on
xline(soglia, 'r--', 'Threshold');
title('Distribuzione errore di ricostruzione (Unhealthy)');

% Conta quante finestre superano la soglia
nSegments_unhealthy = numel(reconstructionError_unhealthy);
nAnomalie_unhealthy = sum(reconstructionError_unhealthy > soglia);
fprintf('Anomalie (unhealthy) trovate: %d su %d segmenti.\n', nAnomalie_unhealthy, nSegments_unhealthy);

%% =============================================================================
% FUNZIONI LOCALI
% =============================================================================
function dataTable = load_data_by_level(main_path, varargin)
% load_data_by_level carica i file .txt dalle sottocartelle di main_path
% per i livelli specificati in varargin (es. "Pitting_degradation_level_0" o "Pitting_degradation_level_1"...).
% Ritorna un'unica tabella dataTable.

filelist = dir(fullfile(main_path, '**', '*.txt'));
data_cell = {};

for k = 1:numel(filelist)
    folderK = filelist(k).folder;
    % Verifica se la cartella corrisponde a uno dei livelli passati in varargin
    isLevelMatch = false;
    for v = 1:numel(varargin)
        if contains(folderK, varargin{v})
            isLevelMatch = true;
            break;
        end
    end
    if ~isLevelMatch
        continue;  % Salta se non corrisponde
    end

    full_filename = fullfile(filelist(k).folder, filelist(k).name);
    data = readmatrix(full_filename, 'Delimiter',' ');
    [~, nCols] = size(data);
    if nCols < 4
        warning('Il file %s ha meno di 4 colonne. Saltato.', full_filename);
        continue;
    end
    % Crea la struttura
    data_struct.data = data;
    data_struct.name = full_filename;
    data_cell{end+1} = data_struct;
end

% Crea la tabella usando la funzione datatable (che devi avere nel path)
Fs = 20480; % sample rate
dataTable = datatable(data_cell, Fs);
end

% -----------------------------------------------------------------------------
function [X, nSegmentsPerFile] = createSegmentsFromTable(dataTable, axisName, segLength, overlap)
% Estrae segmenti dal timetable in dataTable.(axisName){i}
% Restituisce un array 3D [segLength x 1 x nSegmentsTot]
% e un vettore con il numero di segmenti estratti da ogni riga.
nFiles = height(dataTable);
XCell = cell(nFiles,1);
nSegmentsPerFile = zeros(nFiles,1);

for i = 1:nFiles
    tt = dataTable.(axisName){i};  % timetable
    if isempty(tt)
        continue;
    end
    x = tt.Variables;  % estrai la colonna numerica
    segments = segmentSignal(x, segLength, overlap);
    % segments -> [segLength x nSegments]
    segments3D = reshape(segments, segLength, 1, []);
    XCell{i} = segments3D;
    nSegmentsPerFile(i) = size(segments3D,3);
end

X = cat(3, XCell{:});  % Concatena lungo la 3a dimensione
end

% -----------------------------------------------------------------------------
function segments = segmentSignal(x, segLength, overlap)
% Suddivide il vettore x in segmenti di lunghezza segLength,
% con overlap campioni di sovrapposizione.
L = length(x);
step = segLength - overlap;
idxStart = 1:step:(L - segLength + 1);
nSeg = numel(idxStart);
segments = zeros(segLength, nSeg);

for k = 1:nSeg
    idx = idxStart(k) : (idxStart(k) + segLength - 1);
    segments(:,k) = x(idx);
end
end