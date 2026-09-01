# Piano della tesi

## Tesi di lavoro

La tesi studia come rendere eseguibile e misurabile su un sistema HPC un workflow R/BIOMOD2 per Species Distribution Models. Il confronto riguarda soprattutto la rappresentazione dei raster di proiezione e il numero di worker, mantenendo separati i risultati scientifici dalle ottimizzazioni ancora sperimentali.

## Struttura proposta

1. **Introduction and motivation**: contesto ecoinformatico, problema computazionale, obiettivi e contributi.
2. **Background**: SDM, dati di presenza, raster ambientali, pseudo-assenze, ensemble e scenari climatici.
3. **Related work**: da scrivere dopo aver definito i riferimenti bibliografici pertinenti. Le citazioni attuali nel `.bib` appartengono in gran parte a un altro progetto e non vanno riutilizzate automaticamente.
4. **Requirements analysis**: requisiti scientifici, funzionali, di riproducibilità, risorse e gestione degli errori.
5. **Design**: pipeline per specie, separazione calibrazione/proiezione, isolamento degli output e job array Slurm.
6. **Implementation**: R, BIOMOD2, Terra, Singularity, Leonardo e controlli introdotti nel workflow.
7. **Experiments**: domande sperimentali, configurazioni, metriche, confronto storage e worker.
8. **Discussion**: interpretazione, limiti, warning scientifici, generalizzabilità e compromessi RAM/I/O.
9. **Conclusions and future work**: risultati conclusivi e lavoro ancora necessario per la campagna completa.
10. **Appendix**: frammenti di codice selezionati, solo se aiutano la riproducibilità.

## Materiale già utilizzabile

- Dataset: 2,583,359 righe di presenza, 167 specie, risoluzione di 1 km².
- Workflow: cinque algoritmi (`GLM`, `GBM`, `ANN`, `FDA`, `MAXNET`), due ensemble, un ambiente corrente e otto scenari futuri.
- Test di storage: `FALSE/FALSE` completato con circa 261 GiB di MaxRSS; i test `FALSE/TRUE` hanno fallito durante la costruzione della clamping mask.
- Test worker: configurazioni a 4, 6 e 8 worker completate per `Achillea.atrata`; 16 worker `FALSE/FALSE` notificato come completato ma ancora da validare nei dettagli; 32 worker fallito per OOM.
- MAXNET blockwise: confronto locale su 226,775 celle valide, valori mancanti identici e differenza assoluta massima pari a zero. Mancano test completi su raster, RAM, tempi e output.

## Regole di scrittura

- Separare sempre risultato osservato, interpretazione e ipotesi.
- Indicare specie, configurazione, job, unità e numero di ripetizioni.
- Non presentare il registro sperimentale come risultato scientifico definitivo.
- Usare citazioni pertinenti e controllate; non riempire il testo con riferimenti non collegati al progetto.
- Mantenere il testo breve e assertivo, senza promettere la campagna completa prima della sua validazione.
