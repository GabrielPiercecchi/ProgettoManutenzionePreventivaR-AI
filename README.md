# 🤖 ProgettoManutenzionePreventivaR-AI
Progetto di MANUTENZIONE PREVENTIVA PER LA ROBOTICA E L'AUTOMAZIONE INTELLIGENTE

## 📋 Table of Contents

- [🤖 ProgettoManutenzionePreventivaR-AI](#-progettomanutenzionepreventivar-ai)
  - [📋 Table of Contents](#-table-of-contents)
  - [🛠️ Comandi](#️-comandi)
  - [📊 Output Training](#-output-training)
    - [📉 Output Training complete\_autoencoder\_CNN\_pipeline.m](#-output-training-complete_autoencoder_cnn_pipelinem)
    - [📈 Output Training complete\_cnn\_svm.m](#-output-training-complete_cnn_svmm)

## 🛠️ Comandi

- diagnosticFeatureDesigner

## 📊 Output Training

### 📉 Output Training complete_autoencoder_CNN_pipeline.m

```- [ProgettoManutenzionePreventivaR-AI](#progettomanutenzionepreventivar-ai)
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

### 📈 Output Training complete_cnn_svm.m

```
--- Inizio complete_cnn_svm.m ---

--- Caricamento dati di training ---
Carico 287 file da Pitting_degradation_level_0 (Healthy) (label = 0)
Carico 295 file da Pitting_degradation_level_1 (label = 1)
Carico 291 file da Pitting_degradation_level_2 (label = 2)
Carico 267 file da Pitting_degradation_level_3 (label = 3)
Carico 304 file da Pitting_degradation_level_4 (label = 4)
Carico 276 file da Pitting_degradation_level_6 (label = 6)
Carico 296 file da Pitting_degradation_level_8 (label = 8)
Dati training: 6048 segmenti di dimensione [20480 x 3]
--- Caricamento dati di test ---
Carico 800 file di test
Dati test (circa 3 per file): 2400 segmenti di dimensione [20480 x 3]
--- Caricamento dati di validazione ---
Carico 813 file di test
Dati validazione: 2439 segmenti di dimensione [20480 x 3]
Training on single CPU.
|======================================================================================================================|
|  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Validation  |  Mini-batch  |  Validation  |  Base Learning  |
|         |             |   (hh:mm:ss)   |   Accuracy   |   Accuracy   |     Loss     |     Loss     |      Rate       |
|======================================================================================================================|
|       1 |           1 |       00:00:13 |        9.38% |       14.97% |       1.9679 |     120.0127 |          0.0020 |
|       1 |          50 |       00:00:57 |       21.88% |       22.50% |       1.8927 |       1.9358 |          0.0020 |
|       1 |         100 |       00:01:42 |       28.12% |       26.22% |       1.9081 |       1.8847 |          0.0020 |
|       1 |         150 |       00:02:28 |       21.88% |       25.64% |       1.8241 |       1.6400 |          0.0020 |
|       2 |         200 |       00:03:09 |       43.75% |       29.28% |       1.5814 |       1.6748 |          0.0020 |
|       2 |         250 |       00:03:51 |       37.50% |       45.91% |       1.3601 |       1.3223 |          0.0020 |
|       2 |         300 |       00:04:31 |       53.12% |       48.72% |       1.3476 |       1.3335 |          0.0020 |
|       3 |         350 |       00:05:13 |       62.50% |       53.35% |       1.0895 |       1.1522 |          0.0020 |
|       3 |         400 |       00:06:03 |       59.38% |       49.79% |       1.3010 |       1.4562 |          0.0020 |
|       3 |         450 |       00:06:54 |       71.88% |       66.17% |       0.8782 |       0.8987 |          0.0020 |
|       4 |         500 |       00:07:45 |       56.25% |       65.26% |       1.0596 |       0.8996 |          0.0020 |
|       4 |         550 |       00:08:32 |       62.50% |       62.70% |       0.9449 |       0.9451 |          0.0020 |
|       4 |         600 |       00:09:18 |       34.38% |       58.40% |       2.9627 |       0.9814 |          0.0020 |
|       5 |         650 |       00:10:03 |       71.88% |       66.75% |       0.8087 |       0.8642 |          0.0020 |
|       5 |         700 |       00:10:49 |       75.00% |       69.81% |       0.7289 |       0.7310 |          0.0020 |
|       5 |         750 |       00:11:37 |       68.75% |       68.32% |       0.7764 |       0.9000 |          0.0020 |
|       6 |         800 |       00:12:23 |       68.75% |       63.28% |       0.7814 |       0.8921 |          0.0020 |
|       6 |         850 |       00:13:10 |       78.12% |       73.95% |       0.5774 |       0.7245 |          0.0020 |
|       6 |         900 |       00:13:55 |       84.38% |       79.74% |       0.4952 |       0.5194 |          0.0020 |
|       7 |         950 |       00:14:41 |       62.50% |       73.70% |       0.8420 |       0.8012 |          0.0020 |
|       7 |        1000 |       00:15:26 |       78.12% |       66.00% |       0.8935 |       0.9891 |          0.0020 |
|       7 |        1050 |       00:16:14 |       81.25% |       80.98% |       0.5155 |       0.5152 |          0.0020 |
|       8 |        1100 |       00:17:02 |       90.62% |       80.65% |       0.4269 |       0.5093 |          0.0020 |
|       8 |        1150 |       00:17:49 |       81.25% |       79.57% |       0.4106 |       0.6071 |          0.0020 |
|       8 |        1200 |       00:18:34 |       81.25% |       80.48% |       0.4182 |       0.5626 |          0.0020 |
|       9 |        1250 |       00:19:21 |       90.62% |       78.16% |       0.2655 |       0.6856 |          0.0020 |
|       9 |        1300 |       00:20:09 |       87.50% |       81.97% |       0.4255 |       0.5011 |          0.0020 |
|       9 |        1350 |       00:20:56 |       84.38% |       80.65% |       0.5755 |       0.6513 |          0.0020 |
|      10 |        1400 |       00:21:42 |       96.88% |       84.70% |       0.2004 |       0.4835 |          0.0020 |
|      10 |        1450 |       00:22:29 |      100.00% |       81.22% |       0.0860 |       0.6635 |          0.0020 |
|      10 |        1500 |       00:23:15 |       87.50% |       84.37% |       0.3156 |       0.4876 |          0.0020 |
|      11 |        1550 |       00:24:01 |       78.12% |       85.94% |       0.3346 |       0.4414 |          0.0020 |
|      11 |        1600 |       00:24:48 |       84.38% |       74.28% |       0.5231 |       0.7177 |          0.0020 |
|      11 |        1650 |       00:25:35 |       84.38% |       83.79% |       0.2433 |       0.5185 |          0.0020 |
|      12 |        1700 |       00:26:23 |       90.62% |       85.03% |       0.1785 |       0.4837 |          0.0020 |
|      12 |        1750 |       00:27:12 |       93.75% |       82.96% |       0.2535 |       0.6604 |          0.0020 |
|      12 |        1800 |       00:27:58 |       90.62% |       83.37% |       0.2326 |       0.6123 |          0.0020 |
|      13 |        1850 |       00:28:42 |       81.25% |       82.80% |       0.5500 |       0.5321 |          0.0020 |
|      13 |        1900 |       00:29:28 |       75.00% |       69.73% |       0.9312 |       1.0349 |          0.0020 |
|      13 |        1950 |       00:30:14 |       84.38% |       82.13% |       0.4598 |       0.5204 |          0.0020 |
|      14 |        2000 |       00:31:00 |       87.50% |       82.38% |       0.3557 |       0.7414 |          0.0020 |
|      14 |        2050 |       00:31:46 |       81.25% |       85.28% |       0.6983 |       0.6133 |          0.0020 |
|      14 |        2100 |       00:32:33 |       96.88% |       80.31% |       0.0749 |       1.3041 |          0.0020 |
|      15 |        2150 |       00:33:18 |       90.62% |       79.65% |       0.3089 |       0.7312 |          0.0020 |
|      15 |        2200 |       00:34:03 |       84.38% |       76.01% |       0.5136 |       1.0710 |          0.0020 |
|      15 |        2250 |       00:34:49 |       84.38% |       81.06% |       0.4126 |       0.6549 |          0.0020 |
|      15 |        2265 |       00:35:09 |       90.62% |       82.46% |       0.7724 |       0.9018 |          0.0020 |
|======================================================================================================================|
Training finished: Max epochs completed.
Validation accuracy: 0.8246
Matrice di confusione salvata come confusion_matrix.png
...
Segmento 2434 (file: 99_V900_50N.txt): Predetto livello = 3 con confidenza = 1.0000
Segmento 2435 (file: 99_V900_50N.txt): Predetto livello = 3 con confidenza = 0.6317
Segmento 2436 (file: 99_V900_50N.txt): Predetto livello = 3 con confidenza = 0.9996
Segmento 2437 (file: 9_V1500_50N.txt): Predetto livello = 6 con confidenza = 0.8009
Segmento 2438 (file: 9_V1500_50N.txt): Predetto livello = 2 con confidenza = 0.9662
Segmento 2439 (file: 9_V1500_50N.txt): Predetto livello = 6 con confidenza = 0.8686
...
Modello SVM addestrato per la classe base 4.
Modello SVM addestrato per la classe base 6.
Modello SVM addestrato per la classe base 8.
...
Segmento 466 (file: 240_V2100_200N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
Segmento 467 (file: 240_V2100_200N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
Segmento 468 (file: 240_V2100_200N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
Segmento 469 (file: 241_V1000_400N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 470 (file: 241_V1000_400N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 471 (file: 241_V1000_400N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 476 (file: 243_V1200_200N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 477 (file: 243_V1200_200N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 481 (file: 245_V600_400N.txt): Anomalia in 4 (score=-0.5087), riassegnata a 5.
Segmento 482 (file: 245_V600_400N.txt): Anomalia in 4 (score=-0.5087), riassegnata a 5.
Segmento 483 (file: 245_V600_400N.txt): Anomalia in 4 (score=-0.5087), riassegnata a 5.
Segmento 484 (file: 246_V600_500N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
Segmento 485 (file: 246_V600_500N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
Segmento 487 (file: 247_V1000_200N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 488 (file: 247_V1000_200N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 489 (file: 247_V1000_200N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 499 (file: 250_V3000_50N.txt): Anomalia in 4 (score=-0.5086), riassegnata a 5.
Segmento 502 (file: 251_V900_200N.txt): Anomalia in 8 (score=-0.6771), riassegnata a 9.
...
Segmento 2420 (file: 94_V1000_500N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 2421 (file: 94_V1000_500N.txt): Anomalia in 8 (score=-0.6780), riassegnata a 9.
Segmento 2425 (file: 96_V1200_100N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
Segmento 2437 (file: 9_V1500_50N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
Segmento 2439 (file: 9_V1500_50N.txt): Anomalia in 6 (score=-0.6171), riassegnata a 7.
...
File submission_cnn_svm.csv generato con 2400 righe.
File submission_validation_cnn_svm.csv generato con 2439 righe.
TEST - Media: 0.907, Mediana: 1.000, Std: 0.182
VALIDATION - Media: 0.910, Mediana: 1.000, Std: 0.179

Metriche di classificazione sul Validation Set:
Classe  Precision       Recall  F1-score
0       0.717           0.894   0.796
1       0.795           0.652   0.716
2       0.942           0.839   0.888
3       0.655           0.704   0.679
4       0.743           0.902   0.815
6       0.906           0.772   0.833
8       0.978           0.895   0.935
Il grafico delle metriche di classificazione è stato salvato come classification_metrics.png
>> 
```