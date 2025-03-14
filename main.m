clear all; clc;

% Definire il percorso principale
main_path = "B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_training_data\";

% Cercare tutti i file .txt in tutte le sottocartelle
file_list = dir(fullfile(main_path, '**', '*.txt'));

% Creare una cell array per contenere i dati
data_cell = cell(1, numel(file_list));

% Definire il sample rate
Fs = 20480; % Hz

% Loop su tutti i file trovati
for k = 1:numel(file_list)
    % Costruire il percorso completo del file
    full_filename = fullfile(file_list(k).folder, file_list(k).name);

    % Leggere il file
    data = readmatrix(full_filename);

    % Creare il vettore temporale in secondi
    num_samples = size(data, 1);
    time_vector = seconds((0:num_samples-1)' / Fs);  % Vettore temporale come 'duration'

    % Convertire in timetable
    data_cell{k} = timetable(time_vector, data(:,1), data(:,2), data(:,3), data(:,4), ...
        'VariableNames', {'Horizontal_Ax', 'Axial_Ax', 'Vertical_Ax', 'Tachometer'});

    % Stampare il nome del file caricato
    fprintf('📂 Caricato e convertito in timetable: %s\n', full_filename);
end

% Salva i dati in un file .mat
save('data_saved.mat', 'data_cell', '-v7.3');
fprintf('✅ Dati salvati in data_saved.mat\n');