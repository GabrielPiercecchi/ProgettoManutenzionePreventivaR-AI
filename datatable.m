function dataTable = datatable(data_cell, Fs)

% Creazione della tabella vuota
dataTable = table('Size', [numel(data_cell), 0]);

% Iterazione su tutti i file di dati
for i = 1:numel(data_cell)
    % Caricamento dei dati dal file i-esimo
    data = data_cell{i};
    acc_x = data(:, 1);  % Colonna 1 - accelerazione orizzontale (X)
    % acc_y = data(:, 2);  % Colonna 2 - accelerazione assiale (Y)
    acc_z = data(:, 3);  % Colonna 3 - accelerazione verticale (Z)
    tachometer = data(:, 4);  % Colonna 4 - segnale tachimetro
        
    % Converti in timetable per il sample rate
    acc_x = array2timetable(acc_x, 'SampleRate', Fs);
    % acc_y = array2timetable(acc_y, 'SampleRate', Fs);
    acc_z = array2timetable(acc_z, 'SampleRate', Fs);
    tachometer = array2timetable(tachometer, 'SampleRate', Fs);
       
    % Memorizza i dati
    data_cell{i} = table(acc_x, acc_y, acc_z, tachometer);
    
    % Parametri del motore - estratti dal nome del file
    [rpm, torque] = extractMotorParams(data_cell{i});
 
    % Aggiunta dei dati nella tabella finale
    dataTable.acc_x(i) = {acc_x};
    dataTable.acc_y(i) = {acc_y};
    dataTable.acc_z(i) = {acc_z};
    dataTable.tachometer(i) = {tachometer};
    dataTable.motor_speed(i) = {rpm};
    dataTable.torque(i) = {torque};
end

end


function [rpm, torque] = extractMotorParams(data)
    % Supponiamo che il nome del file sia passato insieme ai dati.
    % Per esempio, se hai un nome di file come: 'motor_2000rpm_50torque.txt'
    % estrai i parametri da questa stringa.
    
    filename = data.name;  % Assumendo che 'data' abbia un campo 'name' con il nome del file
    
    % Usa espressioni regolari per estrarre rpm e torque
    rpm_str = regexp(filename, '(?<=_)(\d+)rpm', 'match');  % Estrae i numeri preceduti da "_rpm"
    torque_str = regexp(filename, '(?<=_)(\d+)torque', 'match');  % Estrae i numeri preceduti da "_torque"
    
    % Converti le stringhe in numeri
    rpm = str2double(rpm_str{1});
    torque = str2double(torque_str{1});
end