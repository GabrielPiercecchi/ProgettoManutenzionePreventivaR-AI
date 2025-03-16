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
    % Esempio di file: V900_50N_2.txt
    %   - 900 corrisponde alla velocità (rpm)
    %   - 50  corrisponde alla coppia
    %   - 2   potrebbe essere un indice, non ci interessa

    filename = dataStruct.name;

    % Cerca la velocità: i numeri dopo 'V'
    speed_str = regexp(filename, '(?<=V)\d+', 'match');

    % Cerca la coppia: i numeri tra underscore e 'N'
    torque_str = regexp(filename, '(?<=_)\d+(?=N)', 'match');

    if ~isempty(speed_str)
        rpm = str2double(speed_str{1});
    else
        rpm = NaN;
    end

    if ~isempty(torque_str)
        torque = str2double(torque_str{1});
    else
        torque = NaN;
    end
end    