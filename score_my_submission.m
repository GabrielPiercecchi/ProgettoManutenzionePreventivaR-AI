function score_total = score_my_submission(submissionFile, trueLabels)
    % Calcola lo score totale per una submission, dati i trueLabels.
    % 
    % INPUT:
    %   submissionFile - stringa col nome/path del CSV di submission, ad es. "submission_test.csv"
    %   trueLabels     - vettore col true label per ogni riga (sample). Dev'essere lungo
    %                    quanto il numero di righe del CSV. Valori interi [0..10].
    %
    % OUTPUT:
    %   score_total    - punteggio complessivo calcolato.
    
        % Carica la submission in una tabella
        T = readtable(submissionFile);
    
        % Controlla che la tabella abbia 13 colonne:
        %  1 -> sample_id
        %  2..12 -> prob_0..prob_10
        %  13 -> confidence
        if width(T) ~= 13
            error("La submission deve avere 13 colonne! Controlla il file.");
        end
    
        % Numero di righe
        N = height(T);
    
        % Controlla che la lunghezza di trueLabels corrisponda a N
        if length(trueLabels) ~= N
            error("Dimensione di trueLabels diversa dal numero di righe della submission!");
        end
    
        % Definisci la tabella di punteggio in base alla distanza
        % (distance -> healthStateScore)
        % Distanza 0 => +1.0
        % Distanza 1 =>  0
        % Distanza 2 => -0.5
        % ...
        distScoreMap = [ ... 
            0,   1.0;
            1,   0.0;
            2,  -0.5;
            3,  -1.0;
            4,  -1.5;
            5,  -2.0;
            6,  -2.5;
            7,  -3.0;
            8,  -3.5;
            9,  -4.0;
            10, -4.0
        ];
    
        % Funzione helper per mappare la distanza in healthStateScore
        function s = getHealthStateScore(distance)
            % Se distance > 10 => punteggio -4.0
            if distance > 10
                s = -4.0;
                return;
            end
            rowIdx = find(distScoreMap(:,1) == distance, 1);
            if isempty(rowIdx)
                % in caso di gap, ma qui non dovresti arrivare
                s = -4.0;
            else
                s = distScoreMap(rowIdx,2);
            end
        end
    
        % Inizializza lo score totale
        score_total = 0;
    
        % Per ogni riga (osservazione)
        for i = 1:N
            % Leggi la riga i
            row = T(i,:);
            % Probabilities = colonne 2..12 (prob_0..prob_10)
            probs = row{1,2:12};   % 1x11
            % Confidence = colonna 13
            confVal = row{1,13};
    
            % Verifica sum(probs) <= 1
            sumProbs = sum(probs);
            if sumProbs > 1
                % Heavily penalized => es. punteggio -10 (come da esempio)
                score_observation = -10;
            else
                % Determina il confidenceFactor
                if confVal == 1
                    confidenceFactor = 1.0;
                else
                    confidenceFactor = 0.2;
                end
    
                % Ottieni la true label per questo sample
                trueState = trueLabels(i);
    
                % Calcola la parte di sumProbScore = Σ [prob_s * healthStateScore]
                sumProbScore = 0;
                for s = 0:10
                    dist = abs(trueState - s);
                    hScore = getHealthStateScore(dist);
                    sumProbScore = sumProbScore + probs(s+1)*hScore;
                end
    
                % Score osservazione
                score_observation = confidenceFactor * sumProbScore;
            end
    
            % Aggiungi allo score totale
            score_total = score_total + score_observation;
        end
    
        fprintf("Punteggio totale calcolato = %.4f\n", score_total);
    end    