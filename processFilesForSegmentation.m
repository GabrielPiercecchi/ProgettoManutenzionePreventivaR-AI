function processFilesForSegmentation(directory)
    % processFilesForSegmentation - Elabora tutti i file .txt nella cartella specificata.
    %
    % Per i file in cui la velocità (V) (estratta dal nome del file) è:
    %   - tra 100 e 200 rpm: si assume che il file contenga 12 secondi di dati.
    %     Vengono estratti i primi 3 secondi (3*Fs righe) da ogni blocco da 12 secondi.
    %
    %   - tra 300 e 1000 rpm: si assume che il file contenga 6 secondi di dati.
    %     Vengono estratti i primi 3 secondi (3*Fs righe) da ogni blocco da 6 secondi.
    %
    % Per gli altri valori di V il file non viene modificato.
    %
    % Input:
    %   directory - Path alla cartella contenente i file .txt (ad esempio, 
    %               'B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\')
    %
    % Esempio di utilizzo:
    %   processFilesForSegmentation('B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\')

    Fs = 20480;  % Frequenza di campionamento (campioni al secondo)
    files = dir(fullfile(directory, '*.txt'));
    
    fprintf('Elaborazione dei file nella cartella: %s\n', directory);
    
    for k = 1:length(files)
        filePath = fullfile(files(k).folder, files(k).name);
        % Legge i dati del file
        data = readmatrix(filePath, 'Delimiter', ' ');
        
        % Estrai la velocità (V) dal nome del file (esempio: "V100_50N_2.txt")
        tokens = regexp(files(k).name, 'V(\d+)', 'tokens');
        if isempty(tokens)
            fprintf('File %s: velocità non trovata. Saltato.\n', files(k).name);
            continue;
        end
        V = str2double(tokens{1}{1});
        
        % Imposta i blocchi e il numero di secondi da estrarre in base a V
        if V >= 100 && V <= 200
            blockSize = 12 * Fs;   % blocco da 12 secondi
            extractSize = 3 * Fs;  % estrai 3 secondi
        elseif V >= 300 && V <= 1000
            blockSize = 6 * Fs;    % blocco da 6 secondi
            extractSize = 3 * Fs;  % estrai 3 secondi
        else
            fprintf('File %s: velocità %d rpm fuori range. File non modificato.\n', files(k).name, V);
            continue;
        end
        
        % Calcola il numero di blocchi completi nel file
        numRows = size(data,1);
        numBlocks = floor(numRows / blockSize);
        if numBlocks < 1
            fprintf('File %s: numero di campioni insufficiente per almeno un blocco. File non modificato.\n', files(k).name);
            continue;
        end
        
        % Per ciascun blocco, estrae i primi extractSize campioni
        newData = [];
        for b = 1:numBlocks
            startIdx = (b-1)*blockSize + 1;
            endIdx = startIdx + extractSize - 1;
            newData = [newData; data(startIdx:endIdx, :)];
        end
        
        % Sovrascrive il file con i dati modificati
        writematrix(newData, filePath, 'Delimiter', ' ');
        fprintf('File %s processato: %d blocchi, estratti %d campioni per blocco.\n', ...
                files(k).name, numBlocks, extractSize);
    end
end    