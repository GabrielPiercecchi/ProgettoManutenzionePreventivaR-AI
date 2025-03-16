function train_cnn_autoencoder
    % Assicurati che dataTable sia già nel workspace (generato da load_data.m).
    % Esegui prima load_data.m, poi questo script.
    % Recupera dataTable dal workspace base
    % 1) Verifica l'esistenza di dataTable
    if ~evalin('base', 'exist(''dataTable'', ''var'')')
        error('Devi prima caricare dataTable in workspace (eseguendo load_data.m).');
    end
    dataTable = evalin('base', 'dataTable');
    
    % 2) Parametri di segmentazione
    Fs = 20480;          % Frequenza di campionamento (uguale a load_data)
    secPerSegment = 1;   % Finestra di 1 secondo
    samplesPerSeg = Fs * secPerSegment;  % 20480 campioni per finestra
    overlap = 0;         % Nessun overlap (puoi modificarlo se vuoi)
    
    % 3) Seleziona un asse da analizzare (es. ACC_X)
    axisName = 'acc_x';  % Potresti usare 'acc_y' o 'acc_z'
    
    % 4) Estrai i segmenti da TUTTI i file di dataTable
    [XTrain, ~] = createSegmentsFromTable(dataTable, axisName, samplesPerSeg, overlap);
    % XTrain sarà un array 3D: [samplesPerSeg, 1, nTotSegments]
    %  -> dimensione (lunghezza finestra) x (canali=1) x (numero segmenti)
    % Se vuoi usare 3 assi contemporaneamente come "canali", bisogna modificare la funzione.
    
    % (Opzionale) Se hai "dati sani" vs "dati guasti", potresti filtrare XTrain
    %  qui per addestrare l'autoencoder solo su dati considerati "healthy".
    %  In questo esempio, usiamo TUTTO e vediamo come si comporta.
    
    % Converti XTrain in formato 4D: [samplesPerSeg x 1 x 1 x nSamples]
    XTrain = reshape(XTrain, [samplesPerSeg, 1, 1, size(XTrain, 3)]);

    % 5) Definisci la rete Autoencoder 1D
    %  Esempio semplice con 2 blocchi di conv+pool, poi 2 blocchi di convTrasposta
    layers = [
        imageInputLayer([samplesPerSeg 1 1],"Name","input","Normalization","none") 
        % "imageInputLayer" funziona anche per 1D se la dimensione è [samples x 1 x canali]

        % --- ENCODER ---
        convolution2dLayer([3 1],16,"Padding","same","Name","conv_1")
        reluLayer("Name","relu_1")
        maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_1")  % Riduce la dimensione in 1D

        convolution2dLayer([3 1],8,"Padding","same","Name","conv_2")
        reluLayer("Name","relu_2")
        maxPooling2dLayer([2 1],"Stride",[2 1],"Name","pool_2")

        % --- DECODER ---
        transposedConv2dLayer([4 1],8,"Stride",[2 1],"Cropping","same","Name","transconv_1")
        reluLayer("Name","relu_3")

        transposedConv2dLayer([4 1],16,"Stride",[2 1],"Cropping","same","Name","transconv_2")
        reluLayer("Name","relu_4")

        convolution2dLayer([3 1],1,"Padding","same","Name","conv_3")
        % Niente ReLU finale, perché vogliamo ricostruire il segnale "grezzo"
        
        regressionLayer("Name","regressionOutput")
        ];

    % 6) Opzioni di training
    miniBatchSize = 16;
    maxEpochs = 5; % metti 30 o più in base a quanta pazienza hai
    options = trainingOptions("adam", ...
        "MaxEpochs", maxEpochs, ...
        "MiniBatchSize", miniBatchSize, ...
        "InitialLearnRate",1e-3, ...
        "Plots","training-progress", ...
        "Verbose",true);

    % 7) Addestramento
    % Per l'autoencoder, input = output (ricostruzione)
    % Quindi XTrain e YTrain coincidono
    net = trainNetwork(XTrain, XTrain, layers, options);

    % 8) Esempio di calcolo errore di ricostruzione su TUTTI i segmenti
    % (potresti separare in training/test se vuoi)
    XReconstructed = predict(net, XTrain);
    reconstructionError = mean( (XReconstructed - XTrain).^2, [1 2] ); 
    % -> vettore di dimensione [1, nTotSegments]

    % 9) Visualizza statistica dell'errore
    figure;
    histogram(reconstructionError);
    title('Distribuzione errore di ricostruzione');

    % 10) Esempio: definisci soglia e stima quante "anomalie" ci sono
    soglia = mean(reconstructionError) + 3*std(reconstructionError);
    nAnomalie = sum(reconstructionError > soglia);
    fprintf('Con soglia=%.4f, anomalie trovate: %d su %d segmenti.\n', soglia, nAnomalie, numel(reconstructionError));

    % Fine script
end

% ---------------------------------------------------------------
function [XTrain, nSegmentsPerFile] = createSegmentsFromTable(dataTable, axisName, segLength, overlap)
% Estrae segmenti da TUTTI i file (righe) di dataTable.
% axisName è 'acc_x', 'acc_y' o 'acc_z'.
% segLength = numero di campioni per finestra (es. 20480 per 1s)
% overlap = numero di campioni di sovrapposizione (0 se nessuna).
%
% Restituisce:
%   XTrain: array 3D [segLength, 1, nSegmentsTot]
%   nSegmentsPerFile: array con il numero di segmenti estratti da ogni riga

    nFiles = height(dataTable);
    XCell = cell(nFiles,1);
    nSegmentsPerFile = zeros(nFiles,1);

    for i = 1:nFiles
        % Recupera il segnale dall'asse desiderato
        tt = dataTable.(axisName){i};  % timetable
        x = tt.Variables;             % vettore numerico
        if isempty(x)
            continue;
        end

        % Segmentazione
        segments = segmentSignal(x, segLength, overlap);
        % segments avrà dimensione [segLength, nSegments]
        
        % Lo trasformo in un 3D array: [segLength, 1, nSegments]
        segments3D = reshape(segments, segLength, 1, []);
        
        XCell{i} = segments3D;
        nSegmentsPerFile(i) = size(segments3D,3);
    end

    % Concatena tutti i segmenti nella dimensione 3
    XTrain = cat(3, XCell{:});
end

% ---------------------------------------------------------------
function segments = segmentSignal(x, segLength, overlap)
% Dato un vettore x, restituisce una matrice [segLength, nSegments]
% con i segmenti estratti. overlap = campioni di sovrapposizione.
% Semplice implementazione a blocchi.

    L = length(x);
    step = segLength - overlap;  % passo di avanzamento
    idxStart = 1:step:(L - segLength + 1);

    nSeg = numel(idxStart);
    segments = zeros(segLength, nSeg);

    for k = 1:nSeg
        idx = idxStart(k) : (idxStart(k) + segLength - 1);
        segments(:,k) = x(idx);
    end
end
