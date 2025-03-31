function analyzeCsvAndSaveImage(csvFilePath, outputImagePath)
    % Funzione per analizzare un file CSV, contare i valori massimi per colonna
    % e salvare i risultati in un'immagine .png
    %
    % Input:
    %   csvFilePath - Percorso del file CSV da analizzare
    %   outputImagePath - Percorso del file immagine .png da salvare
    %
    % Output:
    %   Salva un'immagine con i risultati dell'analisi

    % Controlla se il file esiste
    if ~isfile(csvFilePath)
        error('Il file specificato non esiste: %s', csvFilePath);
    end

    % Leggi il file CSV
    data = readtable(csvFilePath);

    % Considera solo le colonne dalla seconda alla penultima
    subset = data{:, 2:end-1};

    % Trova, per ogni riga, la colonna con il valore massimo
    [~, maxColIdx] = max(subset, [], 2);

    % Conta il numero di occorrenze per ogni colonna
    colCounts = histcounts(maxColIdx, 1:size(subset, 2)+1);

    % Crea un grafico a barre per visualizzare i risultati
    figure('Visible', 'off'); % Crea una figura senza mostrarla
    bar(colCounts, 'FaceColor', [0.2, 0.6, 0.8]);
    xlabel('Colonne');
    ylabel('Conteggio');
    title('Distribuzione dei valori massimi per colonna');
    xticks(1:size(subset, 2));
    xticklabels(data.Properties.VariableNames(2:end-1)); % Usa i nomi delle colonne
    grid on;

    % Salva l'immagine come file .png
    saveas(gcf, outputImagePath);

    % Chiudi la figura
    close(gcf);

    fprintf('Immagine salvata con successo in: %s\n', outputImagePath);
end