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
|       1 |           1 |       00:00:01 |        45.33 |       1027.3 |          0.0010 |
|       1 |          50 |       00:00:12 |        35.72 |        638.0 |          0.0010 |
|       1 |         100 |       00:00:22 |        40.02 |        800.9 |          0.0010 |
|       2 |         150 |       00:00:33 |        34.11 |        581.7 |          0.0010 |
|       2 |         200 |       00:00:43 |        23.00 |        264.5 |          0.0010 |
|       3 |         250 |       00:00:54 |        13.15 |         86.5 |          0.0010 |
|       3 |         300 |       00:01:04 |        16.10 |        129.5 |          0.0010 |
|       4 |         350 |       00:01:15 |        10.27 |         52.7 |          0.0010 |
|       4 |         400 |       00:01:24 |        19.12 |        182.9 |          0.0010 |
|       5 |         450 |       00:01:32 |        40.13 |        805.1 |          0.0010 |
|       5 |         500 |       00:01:41 |         9.26 |         42.9 |          0.0010 |
|       5 |         550 |       00:01:49 |        17.63 |        155.4 |          0.0010 |
|========================================================================================|
Training finished: Max epochs completed.
Addestramento completato.
Soglia di errore (healthy) = 0.2214

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
Percentuale di segmenti con alta confidenza: 98.88%

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
Livello medio predetto (test): 0.05
Percentuale di segmenti test con alta confidenza: 98.83%

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
Livello medio predetto (validation): 0.07
Percentuale di segmenti validation con alta confidenza: 98.27%
File submission_validation.csv creato.

[STEP 9] Tuning & Analisi: Visualizzazione di threshold alternativi e statistiche...
Media errore healthy: 0.0227
Std errore healthy: 0.0662
Soglia (media + 3*std): 0.2214
Soglia alternativa (media + 2*std): 0.1552
Soglia alternativa (media + 4*std): 0.2876

==== Fine complete_pipeline_with_analysis.m ====
>> 
```