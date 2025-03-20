%% filterNonHealthySamples.m
% Questo script legge un file CSV di submission (con le colonne sample_id, prob_0, ..., prob_10, confidence)
% e crea un nuovo file CSV che include solo i sample per cui la previsione di salute NON è 0 (sano).
% In altre parole, per ogni riga viene controllato se il massimo (thresholded) non si trova nella colonna prob_0.

% Specifica il nome del file di input (ad es. submission_test.csv)
inputFile1 = 'submission_test.csv';
outputFile1 = 'submission_test_thresholded.csv';

inputFile2 = 'submission_unhealthy.csv';
outputFile2 = 'submission_unhealthy_thresholded.csv';

% Filtra i sample non sani
filterNonHealthySamples(inputFile1, outputFile1);
filterNonHealthySamples(inputFile2, outputFile2);

function filterNonHealthySamples(inputFile, outputFile)
    % filterNonHealthySamples Filtra i sample non sani da un file CSV di submission.

    % Leggi la tabella dal file CSV
    T = readtable(inputFile);

    % Supponiamo che la tabella abbia 13 colonne:
    % Colonna 1: sample_id
    % Colonne 2-12: prob_0 ... prob_10
    % Colonna 13: confidence

    % Estrai la matrice delle probabilità (colonne 2-12)
    probMat = T{:,2:12};

    % Converti ogni riga in un vettore binario:
    % per ogni riga, imposta a 1 l'elemento corrispondente al valore massimo, e 0 gli altri.
    binaryMat = zeros(size(probMat));
    [~, idxMax] = max(probMat, [], 2);  % Trova l'indice del massimo per ogni sample
    for i = 1:size(probMat,1)
        binaryMat(i, idxMax(i)) = 1;
    end

    % Sostituisci le colonne delle probabilità con i vettori binari
    T{:,2:12} = binaryMat;

    % I sample "sani" sono quelli in cui il massimo è nella colonna prob_0 (cioè idxMax == 1)
    healthyRows = (idxMax == 1);
    T_nonHealthy = T(~healthyRows, :);

    % Salva il nuovo file CSV
    writetable(T_nonHealthy, outputFile);

    fprintf('Il file %s è stato creato contenente solo i sample non sani.\n', outputFile);
end
