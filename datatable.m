function dataTable = datatable(data_cell, Fs)
% DATATABLE - Crea una tabella unificata a partire da una cell array di strutture
% contenenti i dati (minimo 4 colonne) e il nome del file.
%
% Input:
%   data_cell : cell array di strutture, ognuna con i campi:
%               .data (la matrice dei dati)
%               .name (il nome o percorso del file)
%   Fs        : sample rate per la conversione in timetable
%
% Output:
%   dataTable : tabella con le colonne:
%               acc_x, acc_y, acc_z, tachometer (come timetable)
%               motor_speed, torque (valori numerici)

% Pre-alloca la tabella finale (6 colonne)
N = numel(data_cell);
dataTable = table('Size', [N 6], ...
    'VariableTypes', {'cell','cell','cell','cell','double','double'}, ...
    'VariableNames', {'acc_x', 'acc_y', 'acc_z', 'tachometer', 'motor_speed', 'torque'});

for i = 1:N
    % Estrai la struttura per il file i-esimo
    dataStruct = data_cell{i};
    
    % Se per qualche motivo dataStruct non è una struttura, emetti un warning
    if ~isstruct(dataStruct)
        warning('Elemento %d di data_cell non è una struttura.', i);
        continue;
    end
    
    data = dataStruct.data;
    
    % Verifica che il file abbia almeno 4 colonne
    if size(data,2) < 4
        warning('Il file %s non ha almeno 4 colonne e verrà saltato.', dataStruct.name);
        continue;
    end
    
    % Estrai le colonne attese
    acc_x = data(:, 1);  % accelerazione orizzontale (X)
    acc_y = data(:, 2);  % accelerazione assiale (Y)
    acc_z = data(:, 3);  % accelerazione verticale (Z)
    tachometer = data(:, 4);  % segnale tachimetro
        
    % Converti gli array in timetable (usando il sample rate)
    acc_x_tt = array2timetable(acc_x, 'SampleRate', Fs);
    acc_y_tt = array2timetable(acc_y, 'SampleRate', Fs);
    acc_z_tt = array2timetable(acc_z, 'SampleRate', Fs);
    tachometer_tt = array2timetable(tachometer, 'SampleRate', Fs);
    
    % Estrai i parametri del motore dal nome del file
    [rpm, torque] = extractMotorParams(dataStruct);
    
    % Aggiungi i dati alla tabella finale
    dataTable.acc_x{i} = acc_x_tt;
    dataTable.acc_y{i} = acc_y_tt;
    dataTable.acc_z{i} = acc_z_tt;
    dataTable.tachometer{i} = tachometer_tt;
    dataTable.motor_speed(i) = rpm;
    dataTable.torque(i) = torque;
end

end

function [rpm, torque] = extractMotorParams(dataStruct)
% EXTRACTMOTORPARAMS - Estrae i parametri rpm e torque dal nome del file
%
% Si assume che il nome del file contenga le informazioni nel formato, ad esempio:
% "V900_50N_2.txt" oppure "motor_2000rpm_50torque.txt".
%
% Input:
%   dataStruct : struttura contenente il campo .name (nome o percorso del file)
%
% Output:
%   rpm        : velocità in rpm (double)
%   torque     : coppia (double)

filename = dataStruct.name;  % Qui filename contiene il percorso completo
% Cerca il pattern: numero seguito da "rpm" preceduto da un underscore
rpm_str = regexp(filename, '(?<=_)(\d+)rpm', 'match');
% Cerca il pattern: numero seguito da "torque" preceduto da un underscore
torque_str = regexp(filename, '(?<=_)(\d+)torque', 'match');

if isempty(rpm_str)
    rpm = NaN;
else
    rpm = str2double(rpm_str{1});
end

if isempty(torque_str)
    torque = NaN;
else
    torque = str2double(torque_str{1});
end
end    