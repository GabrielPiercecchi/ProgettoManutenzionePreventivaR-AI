clear all; clc;

% Definire il percorso principale
main_path = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\";

% Cercare tutti i file .txt in tutte le sottocartelle
filelist = dir(fullfile(main_path, '**', '*.txt'));  % Ottieni tutti i file .txt
% Aggiungere un controllo per verificare il contenuto di filelist
disp(filelist);  % Mostra i file trovati

% Contenere i dati
data_cell = cell(1, numel(filelist));

% Definire il sample rate
Fs = 20480; % Hz

% Stampa il numero di file trovati prima di entrare nel ciclo
fprintf('📂 Numero di file trovati: %d\n', numel(filelist));

% Leggere e convertire tutti i file in datatable
for k = 1:numel(filelist)  % Modifica qui, sostituendo nFiles con numel(filelist)
    % Costruire il percorso completo del file
    full_filename = fullfile(filelist(k).folder, filelist(k).name);  % Accedere ai campi folder e name della struttura
    
    % Leggere il file come matrice
    data = readmatrix(full_filename, 'Delimiter', ' ');
   
    % Creare il vettore temporale in secondi
    num_samples = size(data, 1);
    time_vector = seconds((0:num_samples-1)' / Fs);  % Vettore temporale come 'duration'

    % Creare il datatable
    data_cell{k} = {data};  % Passa i dati come una cella con la matrice

    % Stampare il nome del file caricato
    fprintf('📂 Caricato e convertito in datatable: %s\n', full_filename);
end

% Unire i dati di tutti i file in un'unica tabella
dataTable = datatable(data_cell, Fs);  % Ottieni la tabella unificata

% Computazione delle caratteristiche nel Diagnostic Feature Designer
[feature_Table, data_feature_Table] = extract_features(dataTable);  % Estrazione delle caratteristiche

fprintf("Cleaning the features...\n")

%% Pulizia delle caratteristiche rimuovendo i NaN
feature_Table = standardizeMissing(feature_Table, {-Inf, Inf});  % Rimuovere valori infiniti
countcolumnNaNs = [zeros(1, 4), sum(isnan(table2array(feature_Table(:, 5:end))))];  % Conta i NaN

% Rimuovere caratteristiche con più del 25% di NaN
feature_Table(:, find(countcolumnNaNs > size(feature_Table, 1) / 4)) = [];

% Sostituire il secondo all'ultimo campione: se una caratteristica è NaN, sostituirla con il valore precedente
feature_Table = fillmissing(feature_Table, 'previous');

%% Salvataggio dei dati e tentativo di ricaricare la tabella delle caratteristiche
save('data_feature_Table_zoh.mat', 'data_feature_Table');  % Salvataggio dei dati

clear all  % Pulisce il workspace
load('data_feature_Table_zoh.mat');  % Ricarica i dati salvati

fprintf("Done!\n")