clear all; clc;

% Definire il percorso principale
main_path = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\";

% Cercare tutti i file .txt in tutte le sottocartelle
filelist = dir(fullfile(main_path, '**', '*.txt'));  % Ottieni tutti i file .txt
% Aggiungere un controllo per verificare il contenuto di filelist
disp(filelist);  % Mostra i file trovati

% Contenere i dati
data_cell = {};

% Definire il sample rate
Fs = 20480; % Hz

% Stampa il numero di file trovati prima di entrare nel ciclo
fprintf('📂 Numero di file trovati: %d\n', numel(filelist));

% Ciclo per leggere ogni file
for k = 1:numel(filelist)
    full_filename = fullfile(filelist(k).folder, filelist(k).name);
    
    % Leggi i dati dal file
    data = readmatrix(full_filename, 'Delimiter', ' ');
    [~, nCols] = size(data);
    fprintf('Il file %s ha %d colonne.\n', full_filename, nCols);
    
    % Se il file ha meno di 4 colonne, salta l'elaborazione
    if nCols < 4
        warning('Il file %s ha meno di 4 colonne e verrà saltato!', full_filename);
        continue;
    end
    
    % Crea una struttura contenente i dati e il nome del file
    data_struct.data = data;
    data_struct.name = full_filename;  % puoi usare solo il nome se preferisci
    data_cell{end+1} = data_struct;  % Aggiungi la struttura alla cell array
    
    fprintf('📂 Caricato e convertito in struttura: %s\n', full_filename);
end

% Chiamata della funzione per creare la tabella
dataTable = datatable(data_cell, Fs);

% Computazione delle caratteristiche nel Diagnostic Feature Designer
[feature_Table, data_feature_Table] = extract_features(dataTable);  % Estrazione delle caratteristiche

fprintf("Cleaning the features...\n")

%% Pulizia delle caratteristiche rimuovendo i NaN solo sulle colonne numeriche
% Standardizza i missing nella tabella (applicabile a tutte le colonne)
feature_Table = standardizeMissing(feature_Table, {-Inf, Inf});  

% Calcola il numero di NaN solo sulle colonne numeriche (dalla 5 in poi)
countcolumnNaNs = [zeros(1, 4), sum(isnan(table2array(feature_Table(:, 5:end))))];  

% Rimuove le colonne numeriche che hanno più del 25% di NaN.
colsDaRimuovere = find(countcolumnNaNs > size(feature_Table, 1) / 4);
if ~isempty(colsDaRimuovere)
    feature_Table(:, colsDaRimuovere) = [];
end

% Applica fillmissing solo alle colonne numeriche (dalla 5 in poi)
numericVars = feature_Table(:, 5:end);
numericVars = fillmissing(numericVars, 'previous');
feature_Table(:, 5:end) = numericVars;


%% Salvataggio dei dati e tentativo di ricaricare la tabella delle caratteristiche
save('data_feature_Table_zoh.mat', 'data_feature_Table', '-v7.3');  % Salvataggio dei dati

clear all  % Pulisce il workspace
load('data_feature_Table_zoh.mat');  % Ricarica i dati salvati

fprintf("Done!\n")