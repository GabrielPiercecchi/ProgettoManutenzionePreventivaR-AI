# ProgettoManutenzionePreventivaR-AI
Progetto di MANUTENZIONE PREVENTIVA PER LA ROBOTICA E L'AUTOMAZIONE INTELLIGENTE

## Comandi

- diagnosticFeatureDesigner

## Output Training

```
==== Inizio complete_pipeline_with_analysis.m ====

[STEP 1] Caricamento dati HEALTHY (Pitting_degradation_level_0)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 287
Numero di file healthy caricati: 287
Feature extraction healthy completata.
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
|       1 |           1 |       00:00:01 |        77.96 |       3038.8 |          0.0010 |
|       1 |          50 |       00:00:10 |        35.39 |        626.3 |          0.0010 |
|       1 |         100 |       00:00:19 |        22.80 |        259.9 |          0.0010 |
|       2 |         150 |       00:00:28 |        12.64 |         79.9 |          0.0010 |
|       2 |         200 |       00:00:37 |        28.06 |        393.6 |          0.0010 |
|       3 |         250 |       00:00:45 |        25.74 |        331.3 |          0.0010 |
|       3 |         300 |       00:00:53 |        17.09 |        146.0 |          0.0010 |
|       4 |         350 |       00:01:02 |        27.58 |        380.2 |          0.0010 |
|       4 |         400 |       00:01:10 |        14.06 |         98.8 |          0.0010 |
|       5 |         450 |       00:01:18 |        28.34 |        401.6 |          0.0010 |
|       5 |         500 |       00:01:27 |         9.73 |         47.4 |          0.0010 |
|       5 |         550 |       00:01:35 |        11.09 |         61.5 |          0.0010 |
|========================================================================================|
Training finished: Max epochs completed.
Addestramento completato.
Soglia di errore (healthy) = 0.2356

[STEP 3] Caricamento dati UNHEALTHY (livelli 1..8)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 1729
Numero di file unhealthy caricati: 1729
Feature extraction unhealthy completata.
Segmentazione dei dati unhealthy...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 10782
Segmenti unhealthy totali: 10782

[STEP 4] Valutazione sui dati unhealthy...

[STEP 4] Mapping dei segmenti unhealthy...
Livello medio predetto (unhealthy): 0.05
Percentuale di segmenti con alta confidenza: 98.86%

[STEP 5] Analisi delle condizioni operative...

[STEP 6] Creazione file di submission (Unhealthy)...
Submission (unhealthy) salvata in submission_unhealthy.csv

[STEP 7] Caricamento dati TEST...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 800
Numero di file test caricati: 800
Segmentazione dei dati test...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 4545
Segmenti test totali: 4545

[STEP 7] Predizione sui dati test...

[STEP 7] Mapping dei segmenti test...
Livello medio predetto (test): 0.04
Percentuale di segmenti test con alta confidenza: 98.94%

[STEP 7] Creazione file di submission per dati test...
Submission test salvata in submission_test.csv

==== Fine complete_pipeline_with_analysis.m ====
```