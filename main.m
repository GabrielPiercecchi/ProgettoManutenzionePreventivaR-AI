%% main.m
% Pipeline completa per il progetto PHM America 2023:
% 1. Caricamento dati (load_data.m)
% 2. Addestramento del CNN Autoencoder (train_cnn_autoencoder.m)
%
% Assicurati che i file "load_data.m" e "train_cnn_autoencoder.m" siano nella stessa cartella
% e che producano la variabile "dataTable" (load_data.m) e tutto il necessario per il training.
%
% Esegui questo file per lanciare l'intero processo.

clear; clc; close all;

%% 1. Caricamento dati
fprintf('Caricamento dei dati...\n');
run('load_data.m');  % load_data.m deve creare la variabile "dataTable" nel workspace

if ~exist('dataTable','var')
    error('dataTable non trovato. Verifica il file load_data.m.');
end
fprintf('Dati caricati con successo.\n\n');

%% 2. Addestramento del CNN Autoencoder
fprintf('Avvio addestramento del CNN Autoencoder...\n');
train_cnn_autoencoder;  % Questo script (o funzione) addestra il modello e mostra risultati

fprintf('Addestramento completato.\n');
fprintf('Pipeline eseguita con successo.\n');