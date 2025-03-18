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
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 1773
Segmenti healthy totali: 1773

[STEP 2] Addestramento autoencoder CNN sui dati healthy...
Training on single CPU.
|========================================================================================|
|  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Mini-batch  |  Base Learning  |
|         |             |   (hh:mm:ss)   |     RMSE     |     Loss     |      Rate       |
|========================================================================================|
|       1 |           1 |       00:00:01 |       247.30 |      30577.9 |          0.0010 |
|       1 |          50 |       00:00:33 |        80.82 |       3265.6 |          0.0010 |
|       1 |         100 |       00:01:07 |        46.02 |       1059.1 |          0.0010 |
|       2 |         150 |       00:01:39 |        30.85 |        475.8 |          0.0010 |
|       2 |         200 |       00:02:13 |        58.35 |       1702.3 |          0.0010 |
|       3 |         250 |       00:02:46 |        59.73 |       1783.8 |          0.0010 |
|       3 |         300 |       00:03:19 |        39.69 |        787.7 |          0.0010 |
|       4 |         350 |       00:03:52 |        61.90 |       1915.8 |          0.0010 |
|       4 |         400 |       00:04:25 |        32.06 |        513.9 |          0.0010 |
|       5 |         450 |       00:04:59 |        56.35 |       1587.8 |          0.0010 |
|       5 |         500 |       00:05:31 |        21.15 |        223.7 |          0.0010 |
|       5 |         550 |       00:06:04 |        23.87 |        285.0 |          0.0010 |
|       6 |         600 |       00:06:37 |        42.00 |        882.0 |          0.0010 |
|       6 |         650 |       00:07:10 |        24.42 |        298.3 |          0.0010 |
|       7 |         700 |       00:07:43 |        20.17 |        203.4 |          0.0010 |
|       7 |         750 |       00:08:17 |        41.66 |        867.7 |          0.0010 |
|       8 |         800 |       00:08:50 |        47.94 |       1149.0 |          0.0010 |
|       8 |         850 |       00:09:24 |        31.81 |        506.0 |          0.0010 |
|       9 |         900 |       00:09:57 |        53.20 |       1414.9 |          0.0010 |
|       9 |         950 |       00:10:30 |        27.92 |        389.9 |          0.0010 |
|      10 |        1000 |       00:11:04 |        50.49 |       1274.9 |          0.0010 |
|      10 |        1050 |       00:11:37 |        18.35 |        168.3 |          0.0010 |
|      10 |        1100 |       00:12:10 |        20.73 |        214.9 |          0.0010 |
|========================================================================================|
Training finished: Max epochs completed.
Addestramento completato.
Soglia di errore (healthy) = 0.2050

[STEP 3] Caricamento dati UNHEALTHY (livelli 1..8)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 1729
Numero di file unhealthy caricati: 1729
Feature extraction (unhealthy) completata.
Segmentazione dei dati unhealthy...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 10782
Segmenti unhealthy totali: 10782

[STEP 4] Valutazione su dati unhealthy...

[STEP 4] Mapping dei segmenti unhealthy...
Livello medio predetto (unhealthy): 0.05
Percentuale di segmenti con alta confidenza: 98.98%

[STEP 5] Analisi dei meta-dati (Motor Speed, Torque) sui dati unhealthy...

[STEP 6] Creazione file di submission (Unhealthy)...
File submission_unhealthy.csv creato.

[STEP 7] Caricamento dati TEST...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 800
Numero di file test caricati: 800
Segmentazione dei dati test...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 4545
Segmenti test totali: 4545

[STEP 7] Predizione e mapping sui dati test...
Livello medio predetto (test): 0.04
Percentuale di segmenti test con alta confidenza: 99.19%

[STEP 7] Creazione file di submission per dati test...
File submission_test.csv creato.

[STEP 8] Caricamento dati VALIDATION...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 813
Numero di file validation caricati: 813
Segmentazione dei dati validation...
  [createSegmentsFromTableMulti] Inizio estrazione segmenti...
  [createSegmentsFromTableMulti] Segmenti totali estratti: 4446
Segmenti validation totali: 4446

[STEP 8] Elaborazione dati validation e creazione file CSV...
Livello medio predetto (validation): 0.06
Percentuale di segmenti validation con alta confidenza: 98.76%
File submission_validation.csv creato.

[STEP 9] Tuning & Analisi: Visualizzazione di threshold alternativi e statistiche...
Media errore healthy: 0.0216
Std errore healthy: 0.0611
Soglia (media + 3*std): 0.2050
Soglia alternativa (media + 2*std): 0.1439
Soglia alternativa (media + 4*std): 0.2662

[STEP 10] Creazione file per il Diagnostic Feature Designer...
File diagnosticFeatureData.mat creato per il Diagnostic Feature Designer.

==== Fine complete_pipeline_with_analysis.m ====
```