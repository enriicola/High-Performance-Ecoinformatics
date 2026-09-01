# Backlog del progetto

Le attività sono raggruppate per area. Le voci non marcate restano aperte; una voce può essere chiusa solo dopo una verifica riproducibile.

## Tesi

- [ ] Scrivere e revisionare i capitoli usando i risultati già verificati.
- [ ] Chiedere conferma ai supervisori su titolo, struttura, abstract e contenuto scientifico.
- [ ] Sostituire i placeholder di relatore, correlatore, esaminatore e dedica.
- [ ] Decidere se l'abstract resta nel file principale oppure in `Chapters/abstract.tex`.
- [ ] Aggiungere figure e tabelle solo quando esistono dati e caption verificabili.
- [ ] Preparare le slide tecnica e breve; il dettaglio è in `docs/slides/todo.txt`.
- [ ] Valutare una compilazione LaTeX automatica dopo che la struttura del documento è stabile.

## Validazione scientifica

- [ ] Verificare il CRS dei punti e dei raster; atteso: WGS84 / EPSG:4326.
- [ ] Controllare i warning GLM, MAXNET e metriche con overflow intero.
- [ ] Estrarre e documentare le metriche di valutazione, inclusi TSS e AUC/ROC.
- [ ] Definire quali raster individuali conservare oltre a ensemble, metriche e metadati.
- [ ] Misurare la dimensione degli output per più specie prima di stimare lo spazio totale.
- [ ] Eseguire l'hotspot analysis e scriverne metodo, risultati e limiti.

## Campagna su Leonardo

- [ ] Usare i risultati 4, 6, 8 worker per scegliere una configurazione documentata.
- [ ] Validare il test a 16 worker e gli output prima di usarlo come evidenza.
- [ ] Progettare la campagna completa come un task per specie, con massimo tre nodi concorrenti.
- [ ] Decidere la politica per specie fallite: raccolta degli errori, retry selettivo o stop delle onde successive.
- [ ] Valutare l'ordinamento shortest-job-first senza confonderlo con una riduzione del costo totale.
- [ ] Registrare makespan, CPU-hours, MaxRSS, stato di ogni specie, timing per fase e validazione degli output.
- [ ] Valutare uno script di monitoraggio dei job Slurm: mostrare `squeue --me` e seguire dinamicamente con `tail` i log degli array; `tail` da solo non scopre i nuovi job.

## Ottimizzazione del workflow

- [ ] Completare il confronto MAXNET blockwise su raster intero: tempo, RAM e output.
- [ ] Verificare se lo split dello script modifica memoria, parallelismo o riproducibilità.
- [ ] Misurare l'eventuale contesa I/O a più worker.
- [ ] Ridurre ricalcoli e copie di strutture già caricate, solo quando la misura lo giustifica.
- [ ] Passare sempre il numero di CPU da Slurm a R tramite `BIOMOD_NCPU`.
- [ ] Valutare una strategia di rilascio della RAM tra le fasi; non usare il disco come soluzione automatica senza misura.
- [ ] Valutare `snowfall` solo se serve ancora dopo i test del backend interno di BIOMOD2.

## Infrastruttura e collaborazione

- [ ] Decidere con Lucia come gestire Git LFS: Forgejo, rsync o altra destinazione condivisa.
- [ ] Completare e verificare il workflow rsync tra computer locale, Serviicola e Leonardo.
- [ ] Verificare i codici progetto CINECA con Lucia: `IsCd6_SPECC` e `IscrC_SPECC`.
- [ ] Configurare formatter e LSP per R, eventualmente con pre-commit.
- [ ] Tenere il Makefile come wrapper minimale degli script utili; estenderlo solo se emerge un comando operativo ricorrente.
- [ ] Valutare CUDA in Rocker e supporto SonarQube solo se diventano esigenze concrete del progetto.

## Studio, non urgente

- [ ] Ripassare SIMD/AVX e la nota di Mitchell Hashimoto.
- [ ] Finire gli esercizi HPC elencati in `R/tmp/hello-world.R`.
- [ ] Valutare `broom` solo se serve per l'estrazione delle metriche.
- [ ] Chiarire l'idea di "supermarket scheduling" prima di trasformarla in un requisito.
