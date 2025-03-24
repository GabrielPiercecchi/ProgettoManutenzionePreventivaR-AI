# ProgettoManutenzionePreventivaR-AI
Progetto di MANUTENZIONE PREVENTIVA PER LA ROBOTICA E L'AUTOMAZIONE INTELLIGENTE

## Comandi

- diagnosticFeatureDesigner
- reconstructionError_unhealthy
- B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_test_data\3_V300_400N.txt --> 123904

## Output Training

### Output Training complete_autoencoder_CNN_pipeline.m
```
==== Inizio complete_autoencoder_pipeline.m ====

[STEP 1] Caricamento dati HEALTHY (Pitting_degradation_level_0)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 287
Numero di file healthy caricati: 287
Feature extraction (healthy) completata.
Segmentazione dei dati healthy...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 287
Segmenti healthy totali: 287

[STEP 2] Addestramento autoencoder CNN sui dati healthy...
Training on single CPU.
|========================================================================================|
|  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Mini-batch  |  Base Learning  |
|         |             |   (hh:mm:ss)   |     RMSE     |     Loss     |      Rate       |
|========================================================================================|
|       1 |           1 |       00:00:03 |       429.51 |      92238.5 |          0.0010 |
|       3 |          50 |       00:01:23 |       179.10 |      16039.1 |          0.0010 |
|       6 |         100 |       00:02:44 |       204.31 |      20871.7 |          0.0010 |
|       9 |         150 |       00:04:05 |       100.74 |       5074.0 |          0.0010 |
|      10 |         170 |       00:04:37 |       163.73 |      13403.8 |          0.0010 |
|========================================================================================|
Training finished: Max epochs completed.
Addestramento completato.
Soglia di errore (healthy) = 0.4573

[STEP 3] Caricamento dati UNHEALTHY (livelli 1..8)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 1729
Numero di file unhealthy caricati: 1729
Feature extraction (unhealthy) completata.
Segmentazione dei dati unhealthy...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 1729
Segmenti unhealthy totali: 1729

[STEP 4] Valutazione su dati unhealthy...

[STEP 4] Mapping dei segmenti unhealthy...
Livello medio predetto (unhealthy): 0.01
Percentuale di segmenti con alta confidenza: 100.00%

[STEP 5] Analisi dei meta-dati (Motor Speed, Torque) sui dati unhealthy...

[STEP 6] Creazione file di submission (Unhealthy)...
File submission_unhealthy.csv creato.

[STEP 7] Caricamento dati TEST...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 800
Numero di file test caricati: 800
Segmentazione dei dati test...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 800
Segmenti test totali: 800

[STEP 7] Predizione e mapping sui dati test...
Livello medio predetto (test): 0.01
Percentuale di segmenti test con alta confidenza: 100.00%

[STEP 7] Creazione file di submission per dati test...
File submission_test.csv creato.

[STEP 8] Caricamento dati VALIDATION...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 813
Numero di file validation caricati: 813
Segmentazione dei dati validation...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 813
Segmenti validation totali: 813

[STEP 8] Elaborazione dati validation e creazione file CSV...
Livello medio predetto (validation): 0.02
Percentuale di segmenti validation con alta confidenza: 100.00%
File submission_validation.csv creato.

[STEP 9] Tuning & Analisi: Visualizzazione di threshold alternativi e statistiche...
Media errore healthy: 0.0665
Std errore healthy: 0.1303
Soglia (media + 3*std): 0.4573
Soglia alternativa (media + 2*std): 0.3270
Soglia alternativa (media + 4*std): 0.5876

[STEP 10] Creazione file per il Diagnostic Feature Designer...
File diagnosticFeatureData.mat creato per il Diagnostic Feature Designer.

==== Fine complete_pipeline_with_analysis.m ====
>> 
```

### Output Training complete_cnn_isolation_forest.m
```
==== Inizio complete_autoencoder_CNN_pipeline.m ====

[STEP 1] Caricamento dati HEALTHY (Pitting_degradation_level_0)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 287
Numero di file healthy caricati: 287
Feature extraction (healthy) completata.
Segmentazione dei dati healthy...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 287
Segmenti healthy totali: 287

[STEP 2] Addestramento autoencoder CNN sui dati healthy...
Training on single CPU.
|========================================================================================|
|  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Mini-batch  |  Base Learning  |
|         |             |   (hh:mm:ss)   |     RMSE     |     Loss     |      Rate       |
|========================================================================================|
|       1 |           1 |       00:00:04 |       475.98 |     113277.9 |          0.0100 |
|       3 |          50 |       00:01:22 |        99.24 |       4924.1 |          0.0100 |
|       6 |         100 |       00:02:42 |       131.12 |       8596.2 |          0.0100 |
|       9 |         150 |       00:04:01 |        89.37 |       3993.8 |          0.0100 |
|      10 |         170 |       00:04:32 |       115.49 |       6669.1 |          0.0100 |
|========================================================================================|
Training finished: Max epochs completed.
Addestramento completato.
Soglia di errore (healthy) = 0.2886

[STEP 3] Caricamento dati UNHEALTHY (livelli 1..8)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 1729
Numero di file unhealthy caricati: 1729
Feature extraction (unhealthy) completata.
Segmentazione dei dati unhealthy...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 1729
Segmenti unhealthy totali: 1729

[STEP 4] Valutazione su dati unhealthy...

[STEP 4] Mapping dei segmenti unhealthy...
Livello medio predetto (unhealthy): 0.02
Percentuale di segmenti con alta confidenza: 100.00%

[STEP 5] Analisi dei meta-dati (Motor Speed, Torque) sui dati unhealthy...

[STEP 6] Creazione file di submission (Unhealthy)...
File submission_unhealthy.csv creato.

[STEP 7] Caricamento dati TEST...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 800
Numero di file test caricati: 800
Segmentazione dei dati test...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 800
Segmenti test totali: 800

[STEP 7] Predizione e mapping sui dati test...
Livello medio predetto (test): 0.02
Percentuale di segmenti test con alta confidenza: 100.00%

[STEP 7] Creazione file di submission per dati test...
File submission_test.csv creato.

[STEP 8] Caricamento dati VALIDATION...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 813
Numero di file validation caricati: 813
Segmentazione dei dati validation...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 813
Segmenti validation totali: 813

[STEP 8] Elaborazione dati validation e creazione file CSV...
Livello medio predetto (validation): 0.03
Percentuale di segmenti validation con alta confidenza: 99.88%
File submission_validation.csv creato.

[STEP 9] Tuning & Analisi: Visualizzazione di threshold alternativi e statistiche...
Media errore healthy: 0.0408
Std errore healthy: 0.0826
Soglia (media + 3*std): 0.2886
Soglia alternativa (media + 2*std): 0.2060
Soglia alternativa (media + 4*std): 0.3712

[STEP 10] Creazione file per il Diagnostic Feature Designer...
File diagnosticFeatureData.mat creato per il Diagnostic Feature Designer.

==== Fine complete_pipeline_with_analysis.m ====
>> 
```