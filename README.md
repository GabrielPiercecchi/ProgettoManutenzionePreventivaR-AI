# ProgettoManutenzionePreventivaR-AI
Progetto di MANUTENZIONE PREVENTIVA PER LA ROBOTICA E L'AUTOMAZIONE INTELLIGENTE

## Comandi

- diagnosticFeatureDesigner

## Output Training

```
==== Inizio complete_autoencoder_pipeline.m ====

[STEP 1] Caricamento dati HEALTHY (Pitting_degradation_level_0)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 287
Numero di file healthy caricati: 287
Feature extraction (healthy) completata.
Segmentazione dei dati healthy...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 1773
Segmenti healthy totali: 1773

[STEP 2] Addestramento autoencoder CNN sui dati healthy...
Training on single CPU.
|========================================================================================|
|  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Mini-batch  |  Base Learning  |
|         |             |   (hh:mm:ss)   |     RMSE     |     Loss     |      Rate       |
|========================================================================================|
|       1 |           1 |       00:00:01 |        33.50 |        561.2 |          0.0010 |
|       1 |          50 |       00:00:10 |        60.81 |       1848.9 |          0.0010 |
|       1 |         100 |       00:00:21 |        47.22 |       1114.7 |          0.0010 |
|       2 |         150 |       00:00:32 |        30.61 |        468.6 |          0.0010 |
|       2 |         200 |       00:00:42 |        25.41 |        322.9 |          0.0010 |
|       3 |         250 |       00:00:53 |        15.95 |        127.2 |          0.0010 |
|       3 |         300 |       00:01:04 |        14.38 |        103.4 |          0.0010 |
|       4 |         350 |       00:01:14 |        17.83 |        159.0 |          0.0010 |
|       4 |         400 |       00:01:25 |        25.70 |        330.2 |          0.0010 |
|       5 |         450 |       00:01:36 |        25.40 |        322.5 |          0.0010 |
|       5 |         500 |       00:01:47 |        25.18 |        317.0 |          0.0010 |
|       5 |         550 |       00:01:58 |        24.46 |        299.1 |          0.0010 |
|========================================================================================|
Training finished: Max epochs completed.
Addestramento completato.
Soglia di errore (healthy) = 0.2355

[STEP 3] Caricamento dati UNHEALTHY (livelli 1..8)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 1729
Numero di file unhealthy caricati: 1729
Feature extraction (unhealthy) completata.
Segmentazione dei dati unhealthy...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 10782
Segmenti unhealthy totali: 10782

[STEP 4] Valutazione su dati unhealthy...

[STEP 4] Mapping dei segmenti unhealthy...
Livello medio predetto (unhealthy): 0.05
Percentuale di segmenti con alta confidenza: 98.86%

[STEP 5] Analisi dei meta-dati (Motor Speed, Torque) sui dati unhealthy...

[STEP 6] Creazione file di submission (Unhealthy)...
File submission_unhealthy.csv creato.

[STEP 7] Caricamento dati TEST...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 800
Numero di file test caricati: 800
Segmentazione dei dati test...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 4545
Segmenti test totali: 4545

[STEP 7] Predizione e mapping sui dati test...
Livello medio predetto (test): 0.04
Percentuale di segmenti test con alta confidenza: 98.94%

[STEP 7] Creazione file di submission per dati test...
File submission_test.csv creato.

[STEP 8] Caricamento dati VALIDATION...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 813
Numero di file validation caricati: 813
Segmentazione dei dati validation...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 4446
Segmenti validation totali: 4446

[STEP 8] Elaborazione dati validation e creazione file CSV...
Livello medio predetto (validation): 0.06
Percentuale di segmenti validation con alta confidenza: 98.45%
File submission_validation.csv creato.

==== Fine complete_pipeline_with_analysis.m ====
>> 
```