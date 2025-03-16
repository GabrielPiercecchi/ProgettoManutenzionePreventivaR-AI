# ProgettoManutenzionePreventivaR-AI
Progetto di MANUTENZIONE PREVENTIVA PER LA ROBOTICA E L'AUTOMAZIONE INTELLIGENTE

## Comandi

- diagnosticFeatureDesigner

## Output Training

```
==== Inizio Esecuzione complete_pipeline.m ====

[STEP 1] Caricamento dati healthy (Pitting_degradation_level_0)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 287
Numero di file (healthy) caricati: 287
Segmentazione e reshape dei dati healthy...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 1773
Segmenti healthy totali: 1773

[STEP 2] Inizio addestramento autoencoder CNN...
Training on single CPU.
|========================================================================================|
|  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Mini-batch  |  Base Learning  |
|         |             |   (hh:mm:ss)   |     RMSE     |     Loss     |      Rate       |
|========================================================================================|
|       1 |           1 |       00:00:02 |        48.80 |       1190.7 |          0.0010 |
|       1 |          50 |       00:00:12 |        32.83 |        539.1 |          0.0010 |
|       1 |         100 |       00:00:23 |        18.97 |        180.0 |          0.0010 |
|       2 |         150 |       00:00:33 |        25.59 |        327.5 |          0.0010 |
|       2 |         200 |       00:00:44 |        47.30 |       1118.9 |          0.0010 |
|       3 |         250 |       00:00:55 |        29.54 |        436.3 |          0.0010 |
|       3 |         300 |       00:01:05 |        21.40 |        228.9 |          0.0010 |
|       4 |         350 |       00:01:15 |        10.47 |         54.8 |          0.0010 |
|       4 |         400 |       00:01:26 |        26.95 |        363.1 |          0.0010 |
|       5 |         450 |       00:01:36 |        40.95 |        838.5 |          0.0010 |
|       5 |         500 |       00:01:47 |        16.86 |        142.2 |          0.0010 |
|       5 |         550 |       00:01:57 |        23.06 |        265.9 |          0.0010 |
|========================================================================================|
Training finished: Max epochs completed.
Addestramento completato.
Calcolo errore di ricostruzione sui dati healthy...
Soglia di errore (healthy) = 0.2531

[STEP 3] Caricamento dati unhealthy (livelli 1..8)...
  [load_data_by_level] Caricamento file .txt...
  [load_data_by_level] File filtrati: 1729
Numero di file (unhealthy) caricati: 1729
Segmentazione e reshape dei dati unhealthy...
  [createSegmentsFromTable] Inizio estrazione segmenti...
  [createSegmentsFromTable] Segmenti totali estratti: 10782
Segmenti unhealthy totali: 10782

[STEP 4] Valutazione errore di ricostruzione sui dati unhealthy...
Anomalie (unhealthy) trovate: 438 su 10782 segmenti.

==== Fine Esecuzione complete_pipeline.m ====
```