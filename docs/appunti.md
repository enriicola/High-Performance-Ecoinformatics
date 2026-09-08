# Appunti unificati del progetto

## Scopo del documento

Questo file riunisce il contenuto di tutti i documenti che si trovavano in `docs/work-in-progress/` il 2 settembre 2026:

- `README.md`
- `campaign-snapshot.md`
- `new-prompt.txt`
- `notes.md`
- `notes.tex`
- `notes.tex.bak`
- `pre-prompt.txt`
- `prompt.md`
- `run-manifest.md`
- `session-2026-07-03.md`
- `thesis-plan.md`

L'ordine seguito è prima cronologico e poi tematico. Le ripetizioni sono state accorpate, ma sono stati conservati numeri, identificativi dei job, configurazioni, osservazioni, interpretazioni, dubbi, TODO, riferimenti operativi e discrepanze tra documenti. Quando due note descrivono momenti diversi, entrambe restano nel testo con la relativa data.

Il materiale è un quaderno di lavoro, non un insieme di risultati scientifici già definitivi. Occorre continuare a distinguere tra:

1. ciò che è stato osservato;
2. l'interpretazione dell'osservazione;
3. un'ipotesi ancora da verificare;
4. una decisione operativa presa in un momento specifico.

## Come è stata ricostruita la cronologia

La data del file non coincide sempre con la data degli eventi descritti. La ricostruzione usa tre informazioni distinte:

- la data interna dell'evento o del job;
- la data di modifica nel filesystem;
- la cronologia Git disponibile.

Git registra l'archiviazione congiunta degli undici file in `docs/work-in-progress/` nel commit `c4c3872` del 2 settembre 2026 alle 12:17:37. Questo non significa che siano stati scritti tutti allora. Diversi documenti provenivano da percorsi precedenti oppure riassumevano sessioni più vecchie.

### Ordine materiale dei file archiviati

| Data di modifica | File | Ruolo e periodo descritto |
|---|---|---|
| 1 agosto 2026, 15:52 | `notes.tex.bak` | Sintesi intermedia successiva al confronto F/T contro F/F del 20 luglio. |
| 31 agosto 2026, 22:26 | `campaign-snapshot.md` | Provenienza e integrità dello script congelato usato dalla campagna di produzione. |
| 1 settembre 2026, 17:41 | `notes.tex` | Quaderno sperimentale esteso: test storici, benchmark, storage, worker, MAXNET, spazio disco e manutenzione del 3 agosto. |
| 1 settembre 2026, 18:02 | `new-prompt.txt` | Appunto operativo sui tre nodi, sul modello worktree/tmux/agent e sui riferimenti CINECA. |
| 1 settembre 2026, 18:02 | `session-2026-07-03.md` | Ricostruzione della sessione del 3 luglio e dei benchmark completati fino a metà luglio. |
| 1 settembre 2026, 18:02 | `thesis-plan.md` | Tesi di lavoro, struttura proposta e materiale già utilizzabile. |
| 2 settembre 2026, 09:56 | `run-manifest.md` | Manifest rilevato il 31 agosto, quando i primi due task della nuova campagna erano completi e il terzo era ancora in esecuzione. |
| 2 settembre 2026, 11:47 | `pre-prompt.txt` | Istruzioni di lettura per ricostruire stato HPC, MAXNET e prossimi passi senza modificare nulla. |
| 2 settembre 2026, 12:03 | `README.md` | Indice della documentazione e regola su dove conservare note grezze, TODO e testo verificato. |
| 2 settembre 2026, 12:03 | `notes.md` | Breve indice storico che rimanda al quaderno, al piano e all'handoff. |
| 2 settembre 2026, 14:02 | `prompt.md` | Handoff operativo più recente, aggiornato dopo il completamento del task 3 e la rinomina del comando di sincronizzazione in `3sync`. |

### Cronologia Git utile

- Le vecchie note in `notes.md` hanno una storia che parte dal 19 dicembre 2025 e contiene aggiornamenti del 18 febbraio 2026, 3 e 7 luglio, e benchmark documentati tra il 12 e il 13 luglio.
- `docs/run-manifest.md` fu introdotto il 31 agosto 2026 alle 22:20 nel commit `009a06c`.
- `docs/README.md`, `docs/session-2026-07-03.md` e `docs/thesis-plan.md` furono aggiunti il 1 settembre alle 18:31 nel commit `bc76746`.
- Il quaderno `docs/thesis/Chapters/notes.tex` e il backup furono organizzati il 1 settembre alle 17:52 nel commit `2c6b43f`.
- Gli originali fuori da `work-in-progress/` furono rimossi il 2 settembre nel commit `a630f04`, dopo essere stati archiviati.
- `prompt.md` fu aggiornato il 2 settembre alle 14:04 nel commit `9a65203`, che rinominò il target di sincronizzazione in `3sync`.
- `prompt.md` e `run-manifest.md` furono aggiornati di nuovo il 5 settembre nel commit `b37e227`, dopo la diagnosi del 4 settembre. Le date nella tabella precedente descrivono le copie archiviate inizialmente; le versioni eliminate al termine di questo consolidamento includono anche l'aggiornamento successivo.

La cronologia degli eventi, ricostruita sotto, è quindi più affidabile dell'ordine alfabetico o della sola data materiale dei file.

## Mappa dei riferimenti e dei nomi

I documenti furono scritti durante un riordino del repository. Alcuni percorsi citati sono nomi storici:

| Nome negli appunti | Nome corrente o significato |
|---|---|
| `R/base/base_sequential_analysis.R` | `R/base/baseline.R` dopo il refactor del 2 settembre. |
| `R/base/base_sequential_analysis_campaign_49cfdb0.R` | `R/base/baseline_49cfdb0.R`. È lo snapshot della campagna. |
| `R/tmp/base_sequential_analysis_blockwise.R` | `R/tmp/baseline_blockwise.R`. |
| `docs/thesis/Chapters/notes.tex` | Copia archiviata in `docs/work-in-progress/notes.tex`; il percorso originale è stato rimosso. |
| `docs/run-manifest.md` | Copia archiviata in `docs/work-in-progress/run-manifest.md`. |
| `docs/session-2026-07-03.md` | Copia archiviata in `docs/work-in-progress/session-2026-07-03.md`. |
| `docs/thesis-plan.md` | Copia archiviata in `docs/work-in-progress/thesis-plan.md`. |
| `docs/campaign-snapshot.md` | Copia archiviata in `docs/work-in-progress/campaign-snapshot.md`. |
| `make sync` | Nome presente in una nota precedente. Il comando aggiornato è `make 3sync`. |

Gli hash brevi `52004b2`, `354e415`, `bc71039`, `e622491`, `b26fbd3`, `434b6a8`, `6c36715`, `88e03c0` e `49cfdb0` compaiono nel quaderno come riferimenti a revisioni storiche. Non sono risolvibili nell'attuale insieme di oggetti Git locale. Devono essere trattati come identificatori registrati nelle note, non come commit già riverificati nel clone corrente.

## Contesto scientifico e obiettivo del lavoro

La tesi studia come rendere eseguibile, riproducibile e misurabile su un sistema HPC un workflow R/BIOMOD2 per Species Distribution Models applicato agli habitat delle praterie alpine e agli effetti del cambiamento climatico.

Il dataset di lavoro contiene:

- 2.583.359 righe di presenza;
- 167 specie;
- risoluzione spaziale di 1 km²;
- conteggi per specie compresi, nei dati osservati, tra 43 e 170.701 righe;
- 1.475 righe per *Achillea atrata*.

Per ogni specie il workflow:

1. seleziona pseudo-assenze;
2. calibra cinque algoritmi: `GLM`, `GBM`, `ANN`, `FDA` e `MAXNET`;
3. costruisce due ensemble: `EMmean` ed `EMcv`;
4. proietta i modelli sull'ambiente corrente;
5. proietta i modelli su otto scenari climatici futuri;
6. produce valutazioni, tempi, raster individuali, raster ensemble e metadati BIOMOD2.

I raster ambientali hanno circa 64 milioni di celle. Il valore misurato riportato nel quaderno è 63.951.097 celle con cinque variabili. Il percorso dati documentato contiene quattro GCM, `gfdl.esm4`, `ipsl.cm6a.lr`, `mpi.esm1.2.hr` e `mri.esm2.0`, ciascuno con `ssp370` e `ssp585`, quindi otto scenari futuri.

Nel vecchio commento dello script congelato compare ancora "5 GCM x 2 SSP", cioè dieci proiezioni. Questo commento è incoerente con i dati, con i timing e con i log verificati, che riportano otto scenari. Gli acronimi GCM e SSP e questo commento devono ancora essere controllati e corretti.

L'obiettivo sperimentale iniziale era completare una run a scala di produzione per *Achillea atrata*, così da ottenere una baseline di tempo e risorse prima di valutare un refactor o avviare tutte le 167 specie. L'obiettivo di campagna successivo è misurare l'intero dataset con una versione fissa e documentata del workflow.

L'indagine era divisa in quattro stadi:

1. usare accounting live e ispezione del codice per individuare le allocazioni che crescono con ogni worker di proiezione;
2. misurare il workflow R invariato e i suoi output come baseline, indipendentemente dalle modifiche successive;
3. progettare la campagna in modo che ogni specie possa completare o fallire senza perdere le misure degli altri indici dell'array;
4. confrontare un'implementazione ottimizzata con la baseline usando gli stessi modelli, celle raster, scenari e controlli sugli output.

Questa misura deve includere:

- makespan della campagna;
- somma dei tempi trascorsi per specie;
- CPU-hours totali;
- specie completate e fallite;
- timing per fase;
- MaxRSS;
- validazione degli output.

Il makespan con tre nodi concorrenti non va confuso con il tempo aggregato che le stesse specie richiederebbero in sequenza.

# Timeline degli appunti e degli esperimenti

## Fase 1: test storici precedenti alla campagna completa

> **Ricordo non verificato di Enrico:** anche al DISTAV alcune esecuzioni terminavano con errori OOM e/o `fork()`.

Le prime run riuscite non specificavano `keep.in.memory` e `do.stack`, quindi usavano i default BIOMOD2 `TRUE/TRUE`. Quelle run producevano soltanto circa 30-35 modelli per specie. Le configurazioni successive da 125 o 250 modelli hanno invece saturato i circa 494 GB disponibili su un nodo DCGP.

Le evidenze storiche principali sono:

- i test legacy associati a `52004b2` e `354e415`, con almeno 16 CPU, fallirono durante l'ensemble forecasting per OOM; alcune run raggiunsero anche il limite di 12 ore;
- il test `bc71039`, con una sola CPU, raggiunse il limite di 12 ore durante il secondo scenario futuro su otto;
- un test non identificato di nove righe su *A. atrata*, con parametri giocattolo e una CPU, terminò in 7:01 con 24 modelli sopravvissuti;
- `e622491`, con input piccolo, una CPU e default T/T, usò due repliche di pseudo-assenze e due ripetizioni di cross-validation; completò proiezione corrente e otto scenari in 50,3 ore;
- `b26fbd3`, con 1.000 righe di Agrostis, una CPU, default T/T e parametri giocattolo, completò circa 30 modelli e otto scenari in 17,2 ore;
- gli esperimenti Agrostis successivi usarono tre repliche di pseudo-assenze, due ripetizioni di cross-validation e cinque algoritmi, producendo circa 30 modelli;
- `47333938`, su *Agrostis capillaris* con 170.701 righe, quattro CPU e default T/T, completò in 4:23 con dieci pseudo-assenze, 24 modelli sopravvissuti e un picco di circa 326 GB;
- `47467973`, ancora su *A. capillaris*, usò 10.000 pseudo-assenze, quattro CPU e default T/T; completò 30 modelli validi in 11:50 con un picco vicino a 359 GB;
- `47510573_1`, su *Potentilla erecta* con 167.345 righe, quattro CPU e default T/T, completò in 11:33 con un picco di circa 360 GB e file di timing presente;
- `47510573_2`, su *Galium anisophyllon* con 5.936 righe, entrò in un ciclo di retry SIGPIPE durante la proiezione e fu cancellato dopo circa 18 ore;
- `47510573_3`, su *Festuca glauca* con 332 righe, ebbe lo stesso ciclo SIGPIPE e fu cancellato dopo circa 18 ore;
- `47574797_2`, rerun sequenziale di *G. anisophyllon*, fallì in 3:12 perché l'output ensemble riportò `writeRaster path does not exist`;
- `47574797_3`, rerun sequenziale di *F. glauca*, completò in circa 23 ore;
- per l'array `47593184_*` resta solo un riepilogo Slurm con stato misto e segnale massimo 9; il dettaglio per task non è stato conservato.

Una run storica riuscita usò certamente 10.000 pseudo-assenze. Tuttavia i confronti non sono controllati, perché cambiano insieme input, specie, ripetizioni delle pseudo-assenze, ripetizioni di cross-validation, numero di modelli validi, worker e modalità di storage.

Le configurazioni citate generano ordini di grandezza diversi:

- circa 30-35 modelli nelle run storiche;
- 125 modelli nella baseline sperimentale con 5 ripetizioni di pseudo-assenze, 5 ripetizioni di cross-validation e 5 algoritmi;
- fino a 250 modelli nella configurazione di produzione con 10 ripetizioni di pseudo-assenze, 5 ripetizioni di cross-validation e 5 algoritmi.

## Fase 2: primo array completo, fine giugno e inizio luglio 2026

L'array `48075655_[1-167]` fu il primo tentativo diretto di elaborare tutte le 167 specie. Fu inviato alla fine di giugno con un limite di tre giorni. Ogni indice selezionava una specie, mentre la QoS long-production permetteva al massimo tre task da un nodo ciascuno in esecuzione contemporanea.

All'inizio l'array restò in attesa perché la durata richiesta si sovrapponeva alla manutenzione DCGP dal 30 giugno 2026 alle 09:00 al 1 luglio alle 09:00.

Dopo la manutenzione partirono, a gruppi di tre, i primi cinque task:

| Specie | Righe di occorrenza | Worker di proiezione documentati |
|---|---:|---:|
| *Achillea atrata* | 1.475 | 1 |
| *Achillea clusiana* | 174 | 1 |
| *Agrostis capillaris* | 170.701 | 4 |
| *Agrostis rupestris* | 4.464 | 1 |
| *Alchemilla fissa* | 1.428 | 1 |

Tutti e cinque furono uccisi per OOM dopo circa 13-17 ore, durante la proiezione futura. La configurazione usava 10 ripetizioni di pseudo-assenze, 5 ripetizioni di cross-validation e 5 algoritmi, quindi poteva arrivare a circa 250 run di modello per specie. Lo script ometteva le opzioni di storage e usava i default T/T. I fallimenti coinvolsero specie grandi e piccole e task con uno o quattro worker.

Con approvazione esplicita, i task restanti furono cancellati per non ripetere lo stesso fallimento 167 volte. Il riferimento `434b6a8` impostò poi `keep.in.memory=FALSE` e `do.stack=FALSE` per le proiezioni correnti e future.

## Fase 3: prime prove disk-backed e sessione del 3 luglio

`48236130_1` iniziò la validazione F/F su *Achillea atrata* con un worker, ma fu interrotto volontariamente prima della proiezione quando si decise di passare alla specie più grande *Agrostis capillaris*.

Il job sostitutivo `48238919_3`, su *A. capillaris* con quattro worker e F/F:

- raggiunse lo scenario futuro 1 di 8 dopo circa 14 ore e 50 minuti;
- raggiunse lo scenario 2 dopo circa 20 ore e 15 minuti;
- a circa 22 ore era ancora attivo e scriveva raster senza OOM;
- fu interrotto prima del completamento per avviare un diverso esperimento su tre specie.

Questa run dimostrò avanzamento senza OOM, ma non una validazione completa.

Il riferimento `6c36715` introdusse un worker sperimentale e switch configurabili in `scripts/sbatch.sh`. Lo script sperimentale:

- riusava i raster di calibrazione già caricati;
- eliminava dalla memoria la tabella completa delle occorrenze dopo la selezione della specie;
- configurava la frazione di memoria Terra e la directory temporanea;
- aggiungeva controlli per il riuso degli output.

L'array `48325677`, task 3-5, occupò tre nodi DCGP:

- `48325677_3`: *Agrostis capillaris*, quattro worker;
- `48325677_4`: *Agrostis rupestris*, un worker;
- `48325677_5`: *Alchemilla fissa*, un worker.

I job sembravano bloccati in `BIOMOD_FormatingData` durante la selezione delle pseudo-assenze. In realtà stavano elaborando: ciascuno usava circa il 99% di una CPU e aveva accumulato circa 100 minuti di CPU.

### Collo di bottiglia delle pseudo-assenze

Con `PA.strategy="random"`, un `SpatRaster` di 64 milioni di celle, 170.000 punti di occorrenza, 10 repliche e 10.000 pseudo-assenze per replica, `bm_PseudoAbsences_random` è molto lento. Non era un blocco del programma.

Profilazione annotata:

- `.get_data_mask()`: 13-15 s;
- `cellFromXY` e aggiornamento della maschera: 1-2 s;
- `spatSample` per replica: circa 7 s;
- scansioni `values()` su 64 milioni di celle: oltre 5 minuti, il collo di bottiglia;
- il ciclo si ripete 10 volte, quindi la fase può durare ore;
- in un'osservazione, una replica con 100 pseudo-assenze richiese circa 60 s.

I parametri 10 repliche e 10.000 pseudo-assenze erano stati richiesti dai biologi e andavano mantenuti per la run completa.

### Modifica CPU e crash per collisione dei file

Durante quella sessione `scripts/sbatch.sh` fu cambiato da `--cpus-per-task=56` a `--cpus-per-task=112`, dopo aver confermato con `sinfo` che i nodi DCGP avevano 112 CPU. La modifica fu inviata a GitHub e portata su Leonardo. In seguito si capì che riservare tutte le CPU non risolveva il problema di memoria e poteva produrre un'allocazione o una contabilizzazione non desiderata.

`48325677_3` fallì dopo 507 minuti, cioè circa 8,45 ore, durante `BIOMOD_EnsembleForecasting`. Terra riportò:

```text
[writeRaster] file exists. You can use 'overwrite=TRUE' to overwrite it
```

La causa osservata fu una collisione tra task paralleli che tentavano di scrivere lo stesso file `proj_current_*.tif`. Questo errore era diverso dagli OOM precedenti. L'annotazione fatta in quel momento concludeva che anche i job 4 e 5 avrebbero incontrato lo stesso crash e che una campagna completa da 167 job avrebbe fallito. Era una previsione operativa basata sull'errore del task 3, non l'esito registrato dei task 4 e 5.

Le azioni annotate erano:

- usare `seed_val <- 42L` per rendere riproducibili le run;
- studiare se `seed.val=42` rende pseudo-assenze e output abbastanza stabili da consentire una ripresa sicura;
- confrontare in `BIOMOD_Projection` `overwrite=FALSE`, che può riusare proiezioni esistenti e risparmiare tempo, con `overwrite=TRUE`, più sicuro dopo modifiche a codice, input o modelli;
- preparare l'array 1-167 soltanto dopo i test.

I commit successivi aggiunsero seed deterministici, gestione di `overwrite`, ordinamento shortest-job-first e marker di successo. La baseline di produzione fu poi ricondotta allo script sequenziale in `R/base/`.

Gli stati finali di `48325677_4` e `_5` non furono registrati nelle note. L'ultima osservazione li vedeva ancora nella selezione delle pseudo-assenze.

## Fase 4: array SJF del 5 luglio

Il 5 luglio una configurazione con richiesta di memoria `--mem=100G` fu provata sulle prime cinque specie ordinate con shortest-job-first. Tutti e cinque i job andarono in OOM durante l'ensemble forecasting corrente.

L'ordinamento shortest-job-first può ridurre il tempo in cui i nodi restano inutilizzati o migliorare il makespan, ma non deve essere presentato come una riduzione del costo computazionale totale. Il 7 luglio il limite di memoria SJF fu portato a 250 GB, come registrato nella storia delle vecchie note; il risultato di quella modifica non è specificato nei file archiviati.

## Fase 5: benchmark split contro monolitico, 12-13 luglio

Il benchmark usò `small_1km_EUNIS.csv`, una replica di pseudo-assenze, 10 pseudo-assenze, una ripetizione di cross-validation e nessuna proiezione futura.

### Serie preliminare, otto run

| Versione | Wall time | MaxRSS |
|---|---:|---:|
| Split 1 | 26m18s | 48,3 GiB |
| Split 2 | 25m53s | 47,1 GiB |
| Split 3 | 25m51s | 48,0 GiB |
| Split 4 | 26m00s | 40,3 GiB |
| Monolitico 1 | 26m14s | 42,9 GiB |
| Monolitico 2 | 26m28s | 45,4 GiB |
| Monolitico 3 | 26m05s | 45,4 GiB |
| Monolitico 4 | 26m26s | 44,2 GiB |

Medie:

- split: 26m01s e 45,9 GiB;
- monolitico: 26m18s e 44,5 GiB;
- differenza media di tempo: 18 s, circa 1,1% a favore dello split;
- differenza media RSS: 1,4 GiB in più per lo split, ma senza separazione stabile.

La quarta run split usò 3,9 GiB meno della corrispondente monolitica e l'RSS split variò da 40,3 a 48,3 GiB. `ctx` era un ambiente R passato per riferimento, non una copia dei dati del workflow.

### Benchmark controllato, dieci run

Condizioni:

- un nodo Leonardo esclusivo, `lrdn3758`;
- seed fisso 42;
- `R_DEBUG_ECHO=false`;
- `OMP_NUM_THREADS=1`;
- esecuzioni seriali alternate;
- MaxRSS misurato con `/usr/bin/time -v`.

| Run | Versione | Durata | MaxRSS |
|---:|---|---:|---:|
| 1 | Split | 26m10s | 47,04 GiB |
| 2 | Monolitico | 26m06s | 47,36 GiB |
| 3 | Monolitico | 26m18s | 47,36 GiB |
| 4 | Split | 25m59s | 47,04 GiB |
| 5 | Split | 26m05s | 47,04 GiB |
| 6 | Monolitico | 26m27s | 47,09 GiB |
| 7 | Monolitico | 26m15s | 48,16 GiB |
| 8 | Split | 26m26s | 47,04 GiB |
| 9 | Split | 26m08s | 47,28 GiB |
| 10 | Monolitico | 27m12s | 48,16 GiB |

| Media | Durata | MaxRSS |
|---|---:|---:|
| Split | 26m10s | 47,09 GiB |
| Monolitico | 26m28s | 47,63 GiB |
| Split meno monolitico | -18s | -0,54 GiB |

Il risultato indica equivalenza pratica nelle condizioni provate. La separazione dello script non introduce un costo evidente e non giustifica, da sola, conclusioni più ampie su memoria, parallelismo o riproducibilità.

## Fase 6: campagna a onde e confronto controllato dello storage, 16-20 luglio

Una campagna da 167 specie organizzata in 56 onde da tre job, con riferimenti `49507005-49507067`, usò cinque worker e F/F. Fu cancellata. L'audit successivo non trovò completamenti validi; durante la prima onda il MaxRSS live era circa 261-316 GiB.

Il backup sintetico annota inoltre:

- la campagna iniziale su tre specie fu cancellata;
- un test successivo fu cancellato;
- due prove T/T, rispettivamente con 2 e 112 worker, fallirono per memoria a circa 478 e 481 GiB;
- nessuna delle due produsse `_SUCCESS` o timing finali;
- non fu trovata alcuna run storica mixed-storage valida;
- dopo il 2 luglio, tutti i 22 log che dichiaravano esplicitamente le impostazioni di runtime usavano F/F;
- una prova ibrida da 112 worker fu scartata perché inutilmente esposta a OOM; il controllo F/F era il fallback con più probabilità di produrre una baseline completa.

### Tre test direttamente confrontabili

Furono occupati i tre nodi disponibili con output isolati e 494.000 MB per job:

| Job | Nodo | Worker | Storage | Output o scopo |
|---|---|---:|---|---|
| `49842976_1` | `lrdn4717` | 2 | F/T | Test ibrido su *Achillea atrata*. |
| `49843592_1` | `lrdn4682` | 4 | F/T | Test ibrido sulla stessa specie. |
| `49844162_1` | `lrdn4376` | 4 | F/F | Controllo più sicuro, output `data/output_disk_sp1_4cpu`. |

Con `--exclusive` rimosso, `--mem=0` riservava 494.000 MB, mentre allocazione CPU e contabilizzazione seguivano i due o quattro worker richiesti. La precedente contabilizzazione di 112 CPU proveniva da uno script remoto obsoleto che conteneva ancora `--exclusive`.

La posta Slurm esterna era configurata con `ARRAY_TASKS`, `END`, `FAIL` e `TIME_LIMIT`. Ogni array con un solo task avrebbe quindi dovuto inviare una notifica finale individuale.

### Risultati

| Job | Stato | Tempo | MaxRSS batch | Punto finale osservato |
|---|---|---:|---:|---|
| `49842976_1` | fallito, exit 1 | 05:44:00 | 413,22 GiB | `mcfork()` non riuscì ad allocare memoria durante la clamping mask del primo scenario futuro. |
| `49843592_1` | fallito, exit 1 | 03:57:25 | 413,80 GiB | Stesso errore e stessa fase. |
| `49844162_1` | completato, exit 0 | 22:33:50 | 260,94 GiB | Otto scenari, timing e `_SUCCESS`. |

Slurm non classificò i due test ibridi come `OUT_OF_MEMORY`. L'errore applicativo fu:

```text
mcfork(): unable to fork, possible reason: Cannot allocate memory
```

Per questo non era corretto dedurre la causa dal solo exit code 1. L'ispezione dei log stabilì che entrambi fallirono per pressione di memoria al fork durante la costruzione della clamping mask del primo scenario futuro.

La run F/F è una baseline valida di runtime e risorse:

- `_SUCCESS` registra task 1, quattro worker BIOMOD e completamento il 20 luglio 2026 alle 18:37:21;
- esistono entrambi i file di timing;
- sono elencati tutti gli otto scenari futuri;
- la directory della specie contiene 1.364 file non vuoti e occupa circa 7,2 GB;
- sono presenti tutte le directory di proiezione individuali ed ensemble, correnti e future;
- sono presenti 127 file di modello, cioè 125 modelli individuali più due ensemble;
- nel log non compare un errore applicativo fatale.

Ripartizione del tempo:

| Fase | Secondi | Minuti | Ore |
|---|---:|---:|---:|
| Formattazione | 4.527,93 | 75,47 | 1,26 |
| Modellazione individuale | 248,85 | 4,15 | 0,07 |
| Modellazione ensemble | 137,30 | 2,29 | 0,04 |
| Proiezione corrente | 7.047,56 | 117,46 | 1,96 |
| Proiezione ensemble corrente | 1.421,92 | 23,70 | 0,40 |
| Proiezioni future | 67.818,98 | 1.130,32 | 18,84 |

La maggior parte del tempo è quindi nelle proiezioni future. I warning non fatali GLM, MAXNET e sulle metriche ensemble devono essere controllati prima di considerare scientificamente definitive le metriche di valutazione. Non invalidano la baseline di esecuzione.

## Fase 7: confronto tra storage T/F e numero di worker, 2 agosto

Tre run dal riferimento `88e03c0` completarono il 2 agosto 2026. Ognuna:

- riservò 494.000 MB;
- elaborò il task 1, *Achillea atrata*;
- usò una directory di output isolata;
- limitò le fasi ensemble a due worker.

| Job | Nodo | Worker | Storage | Tempo | MaxRSS | File |
|---|---|---:|---|---:|---:|---:|
| `51485472_1` | `lrdn4939` | 4 | T/F | 80.500 s, 1.341,67 min, 22,36 h | 264,69 GiB | 1.368 non vuoti |
| `51494635_1` | `lrdn4454` | 6 | F/F | 64.256 s, 1.070,93 min, 17,85 h | 258,95 GiB | 1.368 non vuoti |
| `51485581_1` | `lrdn4946` | 8 | F/F | 54.335 s, 905,58 min, 15,09 h | 278,67 GiB | 1.368 non vuoti |

I job da quattro e otto worker erano stati inviati con limite di quattro giorni. Restavano pendenti nonostante 127 nodi DCGP apparentemente liberi, perché la manutenzione iniziava il 3 agosto alle 08:00 e terminava il 17 agosto alle 18:00. Con approvazione esplicita, il limite fu ridotto a 30 ore. Entrambi partirono circa alle 16:50. Il job da sei worker fu inviato direttamente con 30 ore e partì alle 16:54:58. Tutti terminarono prima della manutenzione con stato `COMPLETED` ed exit code zero.

### Confronti rispetto alla baseline 4-worker F/F

La baseline originale `49844162_1` durò 81.230 s, cioè 1.353,83 minuti o 22,56 ore.

- T/F con quattro worker risparmiò 730 s, cioè 12,17 minuti o 0,20 ore, pari allo 0,9%, ma aumentò il picco di memoria di 3,75 GiB.
- F/F con sei worker ottenne speedup 1,264 e ridusse il wall time del 20,9%.
- F/F con otto worker ottenne speedup 1,495 e ridusse il wall time del 33,1%.
- Il passaggio da sei a otto worker diede un ulteriore speedup di 1,183 e ridusse il wall time del 15,4%.

Ogni configurazione fu eseguita una sola volta, quindi non è disponibile una misura della variabilità tra run.

### Timing per fase

| Configurazione | Formattazione | Proiezione corrente | Ensemble corrente | Ciclo futuro completo |
|---|---:|---:|---:|---:|
| 4 worker T/F | 4.490,02 s, 74,83 min, 1,25 h | 6.988,68 s, 116,48 min, 1,94 h | 1.467,62 s, 24,46 min, 0,41 h | 67.139,91 s, 1.119,00 min, 18,65 h |
| 6 worker F/F | 4.600,66 s, 76,68 min, 1,28 h | 5.132,52 s, 85,54 min, 1,43 h | 1.451,78 s, 24,20 min, 0,40 h | 52.735,75 s, 878,93 min, 14,65 h |
| 8 worker F/F | 4.531,17 s, 75,52 min, 1,26 h | 4.057,93 s, 67,63 min, 1,13 h | 1.448,78 s, 24,15 min, 0,40 h | 43.996,87 s, 733,28 min, 12,22 h |

La formattazione restò tra 4.490,02 e 4.600,66 s. L'ensemble corrente restò tra 1.448,78 e 1.467,62 s. Queste fasi non beneficiarono in modo evidente dell'aumento dei worker.

### Utilizzo CPU

| Worker | CPU-hours Slurm | CPU-hours allocate | Utilizzo medio in core | Percentuale dell'allocazione |
|---:|---:|---:|---:|---:|
| 4 | 70,68 | 89,44 | 3,16 | 79,0% |
| 6 | 72,95 | 107,09 | 4,09 | 68,1% |
| 8 | 72,51 | 120,74 | 4,80 | 60,0% |

L'aumento dei worker ridusse il wall time ma abbassò la percentuale media di utilizzo delle CPU allocate.

### Validazione degli output

Tutte e tre le directory:

- contengono 1.368 file;
- non contengono file vuoti;
- contengono entrambe le tabelle di timing;
- contengono `_SUCCESS` non vuoto;
- occupano 7,3-7,4 GB;
- hanno strutture relative identiche dopo la normalizzazione dell'identificatore numerico BIOMOD2;
- non mostrano errori fatali, OOM o fork failure nei log;
- mostrano tutti gli otto scenari futuri;
- registrano 1.143 scritture di proiezione, corrispondenti a 125 modelli individuali più due ensemble per l'ambiente corrente e gli otto futuri.

Il worker elimina l'intera directory della specie prima della formattazione. Nessuno dei 1.368 file precede l'avvio del relativo job e nessun log segnala skip o file preesistenti. Le circa 71-73 CPU-hours per run sono un'ulteriore evidenza di ricalcolo completo.

Restano warning ripetuti sulle probabilità GLM, overflow interi, metriche mancanti e il pacchetto opzionale `cito`. Sono questioni di revisione scientifica, non fallimenti di esecuzione.

## Fase 8: test ad alto numero di worker e manutenzione del 3 agosto

Tre test ulteriori furono inviati il 2 agosto dal riferimento `88e03c0`, con limite di 14 ore per terminare prima della manutenzione. Il limite non implicava che il workload fosse noto come completabile in quel tempo.

### Sedici worker F/F

`51738981_1`:

- nodo `lrdn4795`;
- 16 worker;
- F/F;
- output `data/output_disk_sp1_16cpu`;
- notifica Slurm di completamento con exit code zero;
- durata 37.290 s, cioè 621,50 minuti o 10,36 ore;
- a un controllo intermedio, dopo 15.943 s, 265,72 minuti o 4,43 ore, era allo scenario futuro 3 di 8 e aveva raggiunto 464,77 GiB MaxRSS;
- il MaxRSS finale e la validazione degli output non furono raccolti prima della manutenzione.

Il piano della tesi lo riassume come "notificato come completato ma ancora da validare nei dettagli". Non va usato come evidenza completa finché non vengono verificati accounting e output.

### Sedici worker T/F

`51739004_1`:

- nodo `lrdn3936`;
- 16 worker;
- T/F;
- output `data/output_keepmem_sp1_16cpu`;
- stato `OUT_OF_MEMORY`;
- exit code `0:125`;
- durata 10.638 s, cioè 177,30 minuti o 2,96 ore;
- MaxRSS batch 472,57 GiB;
- un `oom_kill` durante la proiezione individuale del primo scenario futuro;
- un worker non ritornò;
- l'ensemble successivo fallì perché il risultato non conteneva tutti i modelli richiesti.

### Trentadue worker F/F

`51739048_1`:

- nodo `lrdn3756`;
- 32 worker;
- F/F;
- output `data/output_disk_sp1_32cpu`;
- stato `OUT_OF_MEMORY`;
- exit code `0:125`;
- durata 5.998 s, cioè 99,97 minuti o 1,67 ore;
- MaxRSS batch 481,16 GiB;
- 12 worker non ritornarono durante la proiezione individuale corrente;
- Slurm registrò 12 eventi `oom_kill`;
- l'ensemble successivo fallì per la mancanza delle proiezioni di alcuni modelli.

Le tre directory erano assenti prima della sottomissione. I log iniziali confermarono coerenza tra CPU Slurm, worker BIOMOD e flag di storage. Le fasi ensemble restarono a due worker. Insieme i tre job occupavano il limite di tre nodi del progetto.

### Dodici worker e limite insufficiente

Dopo che i due OOM liberarono i nodi furono inviati:

- `51756264_1`, 12 worker F/F su `lrdn4863`, output `data/output_disk_sp1_12cpu`;
- `51756286_1`, 12 worker T/F su `lrdn4866`, output `data/output_keepmem_sp1_12cpu`.

I log confermarono 12 worker BIOMOD, due worker ensemble e allocazioni Slurm corrispondenti. Entrambi avevano limite 34.200 s, cioè 570 minuti o 9,50 ore.

- partirono rispettivamente alle 22:19:55 e 22:20:27;
- raggiunsero `TIME_LIMIT` dopo 34.220 s, cioè 570,33 minuti o 9,51 ore, e 34.218 s, cioè 570,30 minuti o 9,51 ore;
- i tempi misurano il limite imposto, non la durata completa del workload.

### Piano di validazione rinviato

Per `51738981_1` fu preparato un controllo read-only da una CPU, 4 GiB e 30 minuti. Avrebbe verificato:

- accounting Slurm finale;
- `_SUCCESS`;
- tabelle di timing e valutazione;
- numero totale di file e file vuoti;
- 225 raster MAXNET;
- otto righe di timing futuro;
- otto scenari nei log;
- 1.143 scritture di proiezione;
- marker fatali nei log;
- spazio disco;
- eventuali file precedenti all'avvio del job.

Il job di validazione non fu inviato.

### Manutenzione e accesso

Leonardo annunciò la chiusura di tutte le sessioni utente alle 09:30 del 3 agosto e disconnesse il login attivo. Un successivo tentativo tramite `scripts/leogin.sh` raggiunse il flusso SSO CINECA ma andò in timeout prima dell'autenticazione. Non stabilì quindi se un login node fosse raggiungibile dopo l'autenticazione.

La prenotazione Slurm osservata arrivava al 17 agosto alle 18:00. L'avviso CINECA indicava:

- outage previsto dei compute node dal 3 al 7 agosto;
- produzione normale non garantita fino al 14 agosto;
- possibile indisponibilità di accesso e filesystem.

I job di produzione non potevano eseguire durante l'outage. L'invio in coda avrebbe potuto tornare possibile prima del 17 agosto se login, Slurm e filesystem fossero rientrati. Al momento descritto dal quaderno non erano in coda job di validazione o di campagna e non era ancora stata scelta una configurazione per la campagna completa.

## Fase 9: campagna di produzione successiva, fine agosto e 2 settembre

Questa fase è successiva alla frase del quaderno "nessuna campagna è attualmente in coda". Il manifest del 31 agosto e l'handoff del 2 settembre descrivono una nuova campagna reale.

### Snapshot dello script

`R/base/base_sequential_analysis_campaign_49cfdb0.R`, oggi `R/base/baseline_49cfdb0.R`, è una copia congelata dello script usato dalla campagna di produzione.

Non è:

- uno snapshot Git speciale;
- un worktree;
- un clone.

È un artefatto materializzato. Il nome conserva il riferimento sorgente `49cfdb0`. Lo SHA-256 verificato è:

```text
11faf284ac01e00aeee16e48fc8938855edc624d956e5859330cc9b0625c9c7a
```

Slurm esegue questo file tramite percorso assoluto su Leonardo. Modifiche successive a branch, worktree o GitHub non possono quindi alterare un job già inviato.

La copia congelata deriva da uno script chiamato in precedenza `ensamble_modelling_no_parallel`. Rispetto alla versione Windows della collaboratrice, lo script adattato a Leonardo sostituiva i percorsi, eliminava il cluster `doParallel` esterno che si bloccava nel container, rimuoveva la dipendenza da `dplyr`, correggeva un errore di sintassi e rendeva indipendente dalla profondità del path il parsing dei nomi futuri. Conservava due correzioni rilevanti: passare `bm.proj` a `BIOMOD_EnsembleForecasting` per evitare una riproiezione interna e impostare `CV.do.full.models=FALSE` per evitare modelli `allRun` e `allData` aggiuntivi.

La copia congelata documenta, tra le altre cose:

- una specie per task dell'array;
- 10 repliche di pseudo-assenze;
- 10.000 pseudo-assenze per replica;
- 5 ripetizioni di cross-validation;
- 5 algoritmi;
- storage di default della campagna F/F;
- numero di worker letto da `BIOMOD_NCPU` o `SLURM_CPUS_PER_TASK`;
- al massimo due worker per le fasi ensemble;
- pulizia della directory della specie prima dell'esecuzione;
- timing in secondi;
- marker `_SUCCESS` scritto alla fine.

### Interpretazione dei tempi per specie

Negli identificativi delle campagne array, il suffisso indica il task: `55020903_1`, per esempio, è il task 1. Lo snapshot legge `SLURM_ARRAY_TASK_ID`, seleziona un solo nome e filtra le relative occorrenze; il wrapper Slurm assegna un nodo al task. Il wall time misura quindi l'intera pipeline di una specie. L'identificativo base `55020903` indica invece l'array o la campagna.

I log forniscono un riscontro diretto:

| Run/task | Specie | Occorrenze | Wall time |
|---|---|---:|---:|
| `55020903_1` | *Achillea atrata* | 1.475 | 25:36:36 |
| `55020903_2` | *Achillea clusiana* | 174 | 21:26:42 |
| `55020903_3` | *Agrostis capillaris* | 170.701 | 33:58:34 |

La somma dei tre wall time, 81:01:52, non è il runtime di una singola run. Per `_1`, le fasi registrate sommano 92.176,47 s, cioè 25:36:16; i circa 20 s rispetto al wall time sono overhead del wrapper.

Il tempo Futuro somma gli otto scenari della stessa specie. CPU-hours e TotalCPU accumulano il lavoro dei processi paralleli, mentre le CPU-hours allocate corrispondono al wall time moltiplicato per le CPU assegnate. Nessuna di queste misure somma automaticamente specie diverse.

Evidenze: `R/base/baseline_49cfdb0.R`, `scripts/sbatch.sh`, `logs/job_55020903_[1-3].log` e `logs/phase_timings_2026-09-06.csv`.

### Stato rilevato il 31 agosto

| Run o output | Stato al 31 agosto | Riferimento annotato |
|---|---|---|
| `data/output` | Trasferito a `F:\HPC_Leonardo\data\output\`; archivio corrente 135 GB. | `scripts/3sync.sh`; verifica Spartaco. |
| `55020903_1`, *Achillea atrata* | Completato; `_SUCCESS`; 2.614 file. | `logs/leonardo-raw/`. |
| `55020903_2`, *Achillea clusiana* | Completato; `_SUCCESS`; 2.614 file. | `logs/leonardo-raw/`. |
| `55020903_3`, *Agrostis capillaris* | Ancora in esecuzione; nessun `_SUCCESS`. | `logs/leonardo-raw/`. |
| Benchmark `output_*` | Conservati su Leonardo e Spartaco; circa 54 GB. | Quaderno e note della sessione del 3 luglio. |
| Snapshot dello script | Archiviato e verificato. | Nota sullo snapshot. |

Leonardo e Spartaco mantengono gli stessi percorsi relativi rispetto alla root del repository. I file pesanti vengono trasferiti con `scripts/3sync.sh`.

### Stato aggiornato il 2 settembre

L'handoff operativo più recente registra:

- `55020903_1`, `_2` e `_3` completati;
- `_SUCCESS` presente per tutti e tre;
- il task 3, *Agrostis capillaris*, completato il 2 settembre 2026 alle 03:52:58;
- durata del task 3: 1 giorno, 9 ore, 58 minuti e 34 secondi;
- i vecchi task `55020903_[4-167]` sono in hold e non devono essere rilasciati;
- l'array sostitutivo `55530303_[4-167%3]` è pending per manutenzione;
- manutenzione Leonardo dal 2 settembre alle 08:00 al 4 settembre alle 08:00;
- la QoS permette al massimo tre nodi concorrenti;
- ogni task dell'array elabora una specie su un nodo.

L'idea annotata in `new-prompt.txt` era valutare se usare uno dei tre nodi per la campagna completa da 1 a 167, accettandone l'esito, e lasciare gli altri due nodi al lavoro già in corso. La formulazione originale era: "come andrà andrà, chi se ne frega". La configurazione effettiva successiva usa invece una concorrenza massima `%3` sulla campagna sostitutiva.

### Stato consolidato al 4 settembre

Il manifest aggiornato dopo la manutenzione registra:

| Run o output | Stato al 4 settembre | Riferimento storico |
|---|---|---|
| `data/output` | Trasferito in `F:\HPC_Leonardo\data\output\`; archivio corrente 135 GB. | `scripts/3sync.sh`; verifica Spartaco. |
| `55020903_1`, `Achillea.atrata` | Completato; `_SUCCESS`; 2.614 file. | `logs/leonardo-raw/`. |
| `55020903_2`, `Achillea.clusiana` | Completato; `_SUCCESS`; 2.614 file. | `logs/leonardo-raw/`. |
| `55020903_3`, `Agrostis.capillaris` | Completato il 2 settembre 2026 alle 03:52:58; `_SUCCESS`; 2.614 file. | `logs/leonardo-raw/`. |
| Campagna restante | Non eseguita; nessun job attivo; saldo ore esaurito. | Stato comunicato da Leonardo. |
| Benchmark `output_*` | Conservati su Leonardo e Spartaco; circa 54 GB. | Quaderno sperimentale e note della sessione del 3 luglio. |
| Snapshot dello script | Archiviato e verificato. | Nota sullo snapshot della campagna. |

Serviicola, Leonardo e Spartaco mantengono ciascuno un clone Git e `container/geospatial.sif`, escluso da Git. I dati pesanti sotto `data/` restano su Leonardo e Spartaco. `make 3sync` trasferisce dati e container da Leonardo a Spartaco attraverso Serviicola senza cancellare file a destinazione. Per un solo percorso, il comando storico esatto è `make 3sync ARGS="<relative-path>"`.

# Inventario cronologico completo delle run

La tabella raccoglie ogni run o campagna con identificatore presente nelle note. Le righe non costituiscono tutte confronti controllati: cambiano specie, pseudo-assenze, modelli, revisione del codice e storage. I campi indicati come non registrati sono lasciati intenzionalmente incompleti e non vengono stimati.

Nella colonna storage:

- T/T significa `keep.in.memory=TRUE`, `do.stack=TRUE`;
- F/T significa `FALSE/TRUE`;
- T/F significa `TRUE/FALSE`;
- F/F significa `FALSE/FALSE`;
- "default T/T" significa che entrambi gli argomenti erano omessi.

| Run o riferimento | Ambito | CPU | Storage | Stato e tempo | Osservazione registrata |
|---|---|---:|---|---|---|
| `52004b2`, `354e415` | Test legacy | almeno 16 | non registrato | falliti, fino a 12 h | OOM durante ensemble forecasting; alcune run raggiunsero 12 h. |
| `bc71039` | Legacy, una specie | 1 | non registrato | fallito, 12 h | Limite durante scenario futuro 2 di 8. |
| Run iniziale non identificata | Test *A. atrata* di 9 righe | 1 | non registrato | completato, 7:01 | Parametri giocattolo; 24 modelli sopravvissuti. |
| `e622491` | Input di test piccolo | 1 | default T/T | completato, 50,3 h | Corrente e otto futuri completati. |
| `b26fbd3` | Test Agrostis da 1.000 righe | 1 | default T/T | completato, 17,2 h | Parametri giocattolo; circa 30 modelli e otto futuri. |
| Serie split/monolitico preliminare | Input piccolo, 8 run | 1 | non applicabile | completato, 25:51-26:28 | 4 split e 4 monolitiche; MaxRSS 40,3-48,3 GiB. |
| Serie split/monolitico controllata | Input piccolo, 10 run | 1 | non applicabile | completato, 25:59-27:12 | 5 split e 5 monolitiche; MaxRSS 47,04-48,16 GiB. |
| `47333938` | *A. capillaris*, 170.701 righe | 4 | default T/T | completato, 4:23 | 10 pseudo-assenze; 24 modelli; picco circa 326 GB. |
| `47467973` | *A. capillaris*, 170.701 righe | 4 | default T/T | completato, 11:50 | 10.000 pseudo-assenze; 30 modelli validi; picco circa 359 GB. |
| `47510573_1` | *P. erecta*, 167.345 righe | 4 | default T/T | completato, 11:33 | Picco circa 360 GB; timing presente. |
| `47510573_2` | *G. anisophyllon*, 5.936 righe | 4 | default T/T | cancellato, circa 18 h | Retry loop SIGPIPE. |
| `47510573_3` | *F. glauca*, 332 righe | 4 | default T/T | cancellato, circa 18 h | Retry loop SIGPIPE. |
| `47574797_2` | *G. anisophyllon*, 5.936 righe | 1 | default T/T | fallito, 3:12 | `writeRaster path does not exist`. |
| `47574797_3` | *F. glauca*, 332 righe | 1 | default T/T | completato, circa 23 h | Rerun sequenziale. |
| `47593184_*` | Array, ambito non registrato | non registrato | non registrato | misto | Stato misto e segnale massimo 9; dettaglio perso. |
| `48075655` | Array 167 specie | 1 o 4 | default T/T | primi 5 OOM, 13-17 h | OOM durante proiezione futura; rimanenti cancellati. |
| `48236130_1` | *A. atrata* | 1 | F/F | interrotto | Fermato prima della proiezione cambiando specie test. |
| `48238919_3` | *A. capillaris* | 4 | F/F | interrotto, circa 22 h | Arrivò allo scenario futuro 2 di 8. |
| `48325677_3` | *A. capillaris* | 4 | non registrato | fallito, 8,45 h | Collisione su file già esistente durante ensemble parallelo. |
| `48325677_4` | *A. rupestris* | 1 | non registrato | esito non registrato | Ultimo stato: selezione pseudo-assenze. |
| `48325677_5` | *A. fissa* | 1 | non registrato | esito non registrato | Ultimo stato: selezione pseudo-assenze. |
| Array non identificato del 5 luglio | Prime 5 specie SJF | non registrato | non registrato | fallito | Con 100 GB, tutti OOM durante ensemble corrente. |
| `49507005-49507067` | Campagna 56 onde, 167 specie | 5 | F/F | cancellata | Nessun completamento valido; MaxRSS live prima onda 261-316 GiB. |
| `49842976_1` | *A. atrata* | 2 | F/T | fallito, 05:44:00 | Fork fallito alla prima clamping mask futura; 413,22 GiB. |
| `49843592_1` | *A. atrata* | 4 | F/T | fallito, 03:57:25 | Stesso punto; 413,80 GiB. |
| `49844162_1` | *A. atrata* | 4 | F/F | completato, 22:33:50 | 260,94 GiB; otto futuri e `_SUCCESS`. |
| `51485472_1` | *A. atrata* | 4 | T/F | completato, 22:21:40 | 264,69 GiB; 1.368 file non vuoti. |
| `51494635_1` | *A. atrata* | 6 | F/F | completato, 17:50:56 | 258,95 GiB; 1.368 file non vuoti. |
| `51485581_1` | *A. atrata* | 8 | F/F | completato, 15:05:35 | 278,67 GiB; 1.368 file non vuoti. |
| `51738981_1` | *A. atrata* | 16 | F/F | notificato completato, 10:21:30 | MaxRSS finale e output non ancora validati. |
| `51739004_1` | *A. atrata* | 16 | T/F | OOM, 02:57:18 | Un `oom_kill` al primo futuro; 472,57 GiB. |
| `51739048_1` | *A. atrata* | 32 | F/F | OOM, 01:39:58 | 12 `oom_kill` nella proiezione corrente; 481,16 GiB. |
| `51756264_1` | *A. atrata* | 12 | F/F | limite, 09:30:20 | Incompleto con limite 9:30. |
| `51756286_1` | *A. atrata* | 12 | T/F | limite, 09:30:18 | Incompleto con limite 9:30. |
| `55020903_1` | *A. atrata*, produzione | configurazione snapshot | F/F | completato entro 31 agosto | `_SUCCESS`; 2.614 file. |
| `55020903_2` | *A. clusiana*, produzione | configurazione snapshot | F/F | completato entro 31 agosto | `_SUCCESS`; 2.614 file. |
| `55020903_3` | *A. capillaris*, produzione | configurazione snapshot | F/F | completato il 2 settembre, 1d 9h 58m 34s | `_SUCCESS`; fine alle 03:52:58. |
| `55020903_[4-167]` | Resto vecchio array | configurazione snapshot | F/F | in hold al 2 settembre | Non rilasciare. |
| `55530303_[4-167%3]` | Array sostitutivo | configurazione snapshot | F/F | pending al 2 settembre | In attesa per manutenzione; massimo 3 concorrenti. |

# Significato delle modalità di storage

BIOMOD2 usa come default:

```text
keep.in.memory = TRUE
do.stack = TRUE
```

## T/T

Con `do.stack=TRUE`, le proiezioni dei modelli individuali vengono combinate in un raster multilayer. Con `keep.in.memory=TRUE`, l'oggetto di proiezione rimane anche nell'oggetto R restituito da BIOMOD2.

Le prime run T/T riuscivano con circa 30-35 modelli, ma le configurazioni da 125-250 modelli hanno raggiunto il limite di memoria del nodo.

## F/F, disk-backed

Con entrambi i valori a `FALSE`:

- ogni proiezione di modello viene scritta in un file separato;
- l'oggetto BIOMOD2 conserva collegamenti ai file invece dello stack completo;
- i layer completati non si accumulano tutti in memoria;
- aumenta l'I/O sul filesystem.

F/F non significa assenza di uso della RAM. Restano in memoria raster ambientali, modelli, processi worker, clamping mask e buffer temporanei. La baseline F/F da quattro worker ha comunque usato 260,94 GiB.

## F/T, ibrido

Con `keep.in.memory=FALSE` e `do.stack=TRUE`, l'oggetto finale non conserva lo stack, ma BIOMOD2 deve comunque costruire il raster multilayer durante la proiezione. I due test controllati sono falliti alla prima clamping mask futura con circa 413 GiB e un errore di fork.

## T/F

Con file separati e `keep.in.memory=TRUE`, l'ispezione del codice BIOMOD2 mostra che il ramo che conserva i valori è interno al ramo `do.stack`. Con `do.stack=FALSE`, il guadagno osservato di T/F rispetto a F/F è stato minimo: 0,9% su una sola run da quattro worker, con 3,75 GiB di picco in più.

Con file separati, impostare anche `keep.in.memory=FALSE` libera inoltre l'oggetto di proiezione restituito. Nessuna delle due opzioni elimina la memoria temporanea usata dentro ogni predizione concorrente.

## Modalità sequenziale più prudente annotata il 3 luglio

Per una proiezione realmente sequenziale e disk-backed del vecchio `R/base/base_sequential_analysis.R` era stato annotato:

```bash
sbatch --export=ALL,BIOMOD_NCPU=1,PROJ_KEEP_IN_MEMORY=false,PROJ_DO_STACK=false \
  --array=1 scripts/sbatch.sh
```

Significato:

- `BIOMOD_NCPU=1`: nessun worker parallelo;
- `keep.in.memory=false`: niente stack trattenuto nell'oggetto R;
- `do.stack=false`: una proiezione su disco per modello.

Gli OOM storici avvenivano durante `mclapply` o `%dopar%` nelle proiezioni. Con più worker, il fork parte con copy-on-write, ma cache Terra/GDAL, modelli e buffer di predizione diventano memoria privata per worker. Non esiste un meccanismo affidabile che aspetti la disponibilità di RAM. Al limite del cgroup, Slurm fa intervenire il kernel e il processo viene ucciso, non è Leonardo a sospendere il job finché si libera memoria. La modalità sequenziale riduce il picco, ma non garantisce il successo se un singolo modello supera la memoria disponibile.

# Meccanismo di memoria e MAXNET blockwise

Il container usa:

- BIOMOD2 4.3.4.5;
- Terra 1.9.11.

Terra riportava:

- `memfrac` predefinito 0,5;
- nessun massimo assoluto di memoria;
- directory temporanea sotto `/tmp`.

Il limite Terra è per processo. Non impone un limite aggregato unico a tutti i worker BIOMOD2.

## Percorso specifico MAXNET

L'ispezione del codice ha distinto MAXNET dagli altri quattro algoritmi:

- i 100 modelli GLM, GBM, ANN e FDA delegano la predizione raster a Terra, che può lavorare per blocchi;
- i 25 modelli MAXNET convertono l'intero raster prima con `as.points()` e poi con `as.data.frame()`;
- ogni raster ha 63.951.097 celle e cinque predittori;
- più worker MAXNET concorrenti possono materializzare contemporaneamente coordinate, cinque colonne di predittori e intermedi di predizione.

L'evidenza restringe quindi il collo di bottiglia a rappresentazioni complete del raster concorrenti, non al solo numero nominale di CPU.

## Diagnostica locale

Un test locale usò:

- un modello MAXNET già salvato;
- un crop di 230.509 celle;
- 226.775 celle complete e confrontabili;
- gli stessi raster predittori;
- il percorso BIOMOD2 esistente;
- un percorso Terra capace di elaborazione blockwise.

Risultati verificati:

- posizioni dei valori mancanti identiche;
- differenza assoluta massima pari a zero;
- valori scalati interi identici, ottenuti arrotondando la predizione moltiplicata per 1.000;
- comportamento della predizione su `data.frame` invariato.

Il test è passato localmente nel container di produzione senza consumare un nodo Leonardo.

Non verifica ancora:

- il raster completo;
- tutti e 25 i modelli MAXNET;
- tutti gli scenari;
- runtime completo;
- MaxRSS;
- identità di tutti i file di output.

## Variante sperimentale

L'entry point storico `R/tmp/base_sequential_analysis_blockwise.R`, oggi `R/tmp/baseline_blockwise.R`, carica `R/tmp/maxnet_blockwise_override.R` prima della baseline non modificata.

L'override:

- registra un metodo `predict()` più specifico per `MAXNET_biomod2_model`;
- per `SpatRaster` delega la predizione numerica a `terra::predict`;
- lascia invariato il percorso su `data.frame`;
- rifiuta raster categorici;
- rifiuta modelli scalati;
- supporta `filename`, `overwrite`, `seedval` e output 0-1000;
- usa `clamp=FALSE` e predizione logistica;
- scrive `INT2S` con `NAflag=-9999` quando è richiesto l'output 0-1000.

Raster categorici e modelli scalati non sono usati dal workflow corrente. La baseline originale rimase invariata. La variante è una diagnosi e non una modifica di produzione. Nessuna campagna da 167 specie fu lanciata sulla base del solo prototipo blockwise.

# Spazio disco, output e politiche di conservazione

Al momento della misura il filesystem riportava:

- circa 1,0 TiB totali;
- 225 GiB usati;
- 800 GiB disponibili.

Un output completo di *Achillea atrata* da otto worker occupava circa 7,4 GiB:

| Componente | Spazio |
|---|---:|
| Directory di proiezione dei modelli individuali, correnti e future | 6,6 GiB |
| Directory di proiezione ensemble | 700 MiB |
| Modelli e metadati BIOMOD2 | 148 MiB |

Un GeoTIFF individuale campionato risultava compresso con LZW secondo `gdalinfo`.

Se tutte le 167 specie avessero la stessa dimensione di *A. atrata*, conservare ogni file richiederebbe circa 1,21 TiB. È una stima, non una misura su più specie. Conservare soltanto i 700 MiB di ensemble e i 148 MiB di modelli e metadati richiederebbe circa 138 GiB, prima dei piccoli file top-level.

Le clamping mask si trovano nella struttura delle proiezioni individuali. Conservarle eliminando gli altri raster richiede una regola selettiva e una nuova misura.

Il numero di righe di occorrenza non permette di scalare direttamente i 6,6 GiB per specie:

- ogni specie completata richiede comunque 125 proiezioni individuali sul raster corrente e sugli otto futuri nella baseline controllata;
- la compressione GeoTIFF dipende dai valori predetti e dai pattern di dati mancanti;
- serve una regressione dimensione/occorrenze basata su più specie completate con gli stessi modelli, raster e storage;
- il confronto controllato disponibile riguarda una sola specie.

`_SUCCESS` dimostra che lo script R ha raggiunto la scrittura finale. Non dimostra da solo che tutti gli output siano stati validati in modo indipendente o che i raster individuali collegati non servano più.

Rimuovere i raster individuali:

- impedirebbe l'ispezione successiva delle mappe per singolo modello;
- invaliderebbe gli oggetti BIOMOD2 che li referenziano;
- richiederebbe un ricalcolo per cambiare ensemble o soglie.

Non è stata applicata alcuna politica automatica di cancellazione.

# Occorrenze, specie e raster blocking

## Distribuzione delle specie nel dataset completo

Il file `data/input/full_1km_EUNIS.csv` contiene 2.583.359 record per 167 specie. Il conteggio è stato ottenuto raggruppando il campo `sp_name` e contando le righe, esclusa l'intestazione. Il risultato descrive quindi il numero di record assegnati a ciascuna specie nel dataset, non una nuova stima delle presenze biologiche.

| Statistica | Record per specie |
|---|---:|
| Minimo | 43 |
| Primo quartile | 2.026 |
| Mediana | 5.936 |
| Media | 15.469,2 |
| Terzo quartile | 14.633 |
| Massimo | 170.701 |

*Galium anisophyllon* è la specie mediana per numerosità delle occorrenze: ha esattamente 5.936 record ed è la 84ª specie nella graduatoria ordinata per conteggio. È quindi il candidato rappresentativo per una prova basata sulla distribuzione dei conteggi delle occorrenze per specie. Le specie più vicine sono *Dichodon cerastoides* (5.912), *Festuca filiformis* (5.992), *Fumana procumbens* (6.098) e *Sagina saginoides* (5.238).

La specie più frequente è invece *Agrostis capillaris* (170.701 record), seguita da *Potentilla erecta* (167.345), *Galium verum* (112.708), *Knautia arvensis* (92.894) e *Luzula campestris* (77.960). Questa è una scelta diversa dalla specie mediana e non va usata come rappresentativa della dimensione tipica senza una motivazione specifica.

Il conteggio completo è conservato in [`docs/full_species_counts.csv`](full_species_counts.csv); la sintesi tabellare e il metodo sono in [`docs/tables/3.full-species-occurrence-distribution.md`](tables/3.full-species-occurrence-distribution.md).

Un secondo confronto ha considerato la distribuzione spaziale. Lo script `scripts/find_representative_species.py` assume che `x` e `y` siano longitudine e latitudine WGS84. Le proietta con una Lambert azimutale equivalente sferica centrata sull'Europa, aggrega le occorrenze su griglie di 5, 10 e 20 km e assegna lo stesso peso a ogni specie. Il medoid spaziale è la specie con la minore divergenza media di Jensen-Shannon dalle altre specie. Il confronto con la distribuzione media è usato come controllo. La verifica del sistema di riferimento delle coordinate (Coordinate Reference System, CRS) rispetto ai raster ambientali è ancora aperta; fino ad allora il ranking è provvisorio.

Se il CRS WGS84 viene confermato, *Phyteuma orbiculare* è prima con celle da 10 e 20 km e seconda con celle da 5 km; è anche prima rispetto alla distribuzione media a 10 e 20 km e seconda a 5 km. È quindi la candidata più solida quando si considera soltanto la geometria spaziale. *Galium anisophyllon* ha invece il conteggio mediano ed è 7ª per distanza spaziale media a tutte e tre le risoluzioni. Questi due criteri non sono combinati in un unico punteggio. Il ranking non misura runtime o memoria e non sostituisce il criterio per numerosità richiesto dalla proiezione preliminare. I risultati completi sono versionati in `data/output/spatial_species_representativeness.csv`.

Dividere le righe di occorrenza di una stessa specie cambierebbe:

- selezione delle pseudo-assenze;
- cross-validation;
- modelli calibrati.

I risultati parziali non ricostruirebbero quindi l'analisi esistente.

Raggruppare più specie complete nello stesso task conserverebbe l'analisi, ma:

- non ridurrebbe la memoria richiesta dalla proiezione di una specie;
- ridurrebbe l'isolamento dei fallimenti per specie.

Il raster blocking è diverso. Un modello già calibrato predice intervalli di righe o tile spaziali consecutivi, scrive ogni blocco e li combina nello stesso raster finale. Cambia la pianificazione della memoria, non i dati di occorrenza o il modello.

## Specie rappresentativa da scegliere

Il medoid è la specie reale con la distanza media minore dalle distribuzioni spaziali delle altre specie. Non è stato definito un punteggio che combini numerosità e distribuzione spaziale, quindi le candidate restano separate per criterio:

- *Phyteuma orbiculare*: distribuzione spaziale più simile alle altre a 10 e 20 km, con 13.877 occorrenze;
- *Scabiosa lucida*: 6ª per vicinanza alla mediana e tra la 4ª e la 6ª posizione nello spazio, con 6.175 occorrenze;
- *Galium anisophyllon*: mediana esatta di 5.936 occorrenze e 7ª per distanza spaziale media;
- *Agrostis capillaris*: massimo di 170.701 occorrenze, come caso limite.

La scelta dipende dal criterio ritenuto rilevante e va concordata con i collaboratori.

# Metodologia di misura e interpretazione

Sono stati usati:

- `sacct` per stato finale, exit code, elapsed e memoria dei job e dei batch step;
- `squeue` per stato live e scadenze;
- `sstat` per MaxRSS live;
- `/usr/bin/time -v` per il massimo per processo o per il comando osservato;
- `du` per blocchi occupati su disco;
- `df` per capacità del filesystem;
- `gdalinfo` per la compressione del GeoTIFF;
- `singularity exec` per versioni BIOMOD2/Terra e `terraOptions()`.

I valori Slurm con suffisso `K` furono convertiti in GiB dividendo per 1.048.576.

Nei job a singolo task, il MaxRSS del batch step include il processo R e i discendenti forkati. Per questo è preferito al massimo più basso del singolo processo riportato da GNU `time`.

Le code dei log hanno permesso di individuare l'operazione precedente al fallimento. Le righe di debug hanno verificato la corrispondenza tra allocazione Slurm, worker R e storage. I marker degli scenari hanno verificato l'avanzamento negli otto futuri.

I successivi errori BIOMOD ensemble nei job OOM non sono la causa iniziale: derivano dalle proiezioni mancanti dopo la perdita dei worker.

Un tentativo di elencare direttamente i processi sui compute node fu respinto dall'autenticazione Leonardo. Nessuna affermazione sull'RSS per processo si basa su quel tentativo.

`du` e `df` misurano disco, non memoria residente.

# Partizioni e QoS Leonardo

Tutti i test descritti usavano `scripts/sbatch.sh`. Le opzioni da linea di comando sovrascrivevano CPU, limite di tempo e variabili dell'esperimento, mentre lo script forniva account, partizione, QoS, memoria, log e posta.

| Risorsa | Ruolo e limiti annotati |
|---|---|
| `dcgp_usr_prod` | Partizione CPU general purpose. Limite normale di un giorno. |
| `dcgp_qos_lprod` | QoS long production. Fino a quattro giorni. Per il progetto: massimo aggregato tre nodi, 336 CPU e 1.482.000 MB. |
| `dcgp_qos_bprod` | QoS production senza estensione separata del wall time nel dato osservato; eredita il giorno della partizione. |
| `dcgp_qos_dbg` | Debug, massimo 30 minuti; limite progetto due nodi, 224 CPU e 988.000 MB. |
| `boost_usr_prod` | Partizione GPU con quattro A100 per nodo, limite osservato un giorno. |
| `lrd_all_serial` | Due nodi seriali, limite quattro ore. |
| `lrd_all_viz` | Nodi di visualizzazione con GPU Quadro, limite dodici ore. |

Queste risorse hanno hardware e obiettivi diversi. Non sono code intercambiabili per lo stesso workload DCGP.

La RAM di nodi separati non viene combinata in modo trasparente. Un'esecuzione multinodo richiederebbe sharding esplicito per modello o scenario e ricombinazione su disco. Doveva essere considerata soltanto se lo storage ibrido avesse continuato a fallire. La campagna effettiva usa invece una specie indipendente per nodo.

# Workflow tra i tre host

## Serviicola

- Clone di lavoro in `/home/ubuntu/tesi`.
- Conserva `container/geospatial.sif`, che resta ignorato da Git.
- Fa da relay per `3sync` senza conservare copie intermedie dei dati pesanti.

## Leonardo

- Root: `/leonardo_work/IscrC_SPECC`.
- Contiene dati pesanti, log e `container/geospatial.sif`.
- I vecchi metadati Git devono essere sostituiti da un clone fresco soltanto dopo la manutenzione, preservando `data/`, `logs/` e il container.
- Per i comandi operativi, l'handoff richiede `tmux send-keys` sulla finestra `tesi:1:leo`, controllo preventivo dello stato del pane e ripristino del monitoraggio log dopo il comando.

## Spartaco

- Clone in `F:\HPC_Leonardo`.
- File pesanti sotto `data\` e `container\geospatial.sif`.

## Git e file pesanti

- Serviicola, Leonardo e Spartaco conservano ciascuno un clone Git e `container/geospatial.sif`.
- GitHub ha un solo branch, `main`.
- Git traccia due piccoli CSV di input e i file testuali root-level `data/output/*.txt`.
- Raster, modelli e SIF restano fuori da Git.
- I dati pesanti sotto `data/` sono conservati su Leonardo e Spartaco, non su Serviicola.
- Git LFS non è usato.
- Le note contengono ancora il TODO di eliminare eventuali credenziali dalle note e dalla storia Git.

## Sincronizzazione

`make 3sync` copia per default:

- `data/`;
- `container/geospatial.sif`.

Per un percorso specifico:

```bash
make 3sync ARGS="<percorso-relativo>"
```

Lo script `scripts/3sync.sh` usa gli stessi percorsi relativi su Leonardo e Spartaco. Copia dati e container da Leonardo a Spartaco passando per Serviicola. Prova prima `rclone`; se fallisce usa `scp -3`. Non cancella i file già presenti a destinazione.

# Modello operativo worktree, tmux e agent

L'appunto del 1 settembre rimanda all'articolo:

<https://spin.atomicobject.com/rebuilding-development-workstation/?utm_source=tldrnewsletter>

La struttura citata è:

```text
branch
  └── Git worktree
        └── tmux session
              ├── shell
              └── agent
```

L'implementazione dell'articolo è specifica per le preferenze dell'autore, ma l'idea generale è considerata più importante dello script. Un minimo di orchestrazione rende naturale creare un workspace pulito per ogni attività, evitando che lavori non correlati condividano branch, directory o contesto del terminale.

Riferimento Leonardo annotato:

<https://docs.hpc.cineca.it/hpc/leonardo.html>

Nello stesso file compaiono questi identificatori di sessione o attività, conservati perché facevano parte degli appunti:

```text
1:leo
2:01a00bf8-1198-7cb9-b45e-aeb25163cebd
3:01a03831-9d4c-7366-8a2b-fa1f748f70c1
```

Nel TODO corrente sono descritti così:

- `01a00bf8-1198-7cb9-b45e-aeb25163cebd`: ricerca e soluzione degli OOM, più trial run del blockwise override, vecchia sessione;
- `01a03831-9d4c-7366-8a2b-fa1f748f70c1`: riordino e completamento delle attività Leonardo dopo la manutenzione del 4 settembre alle 08:00.

Poiché esiste anche il TODO "rimuovere le credenziali dalle note e purgarle dalla storia Git", questi identificatori devono essere classificati prima di pubblicare il materiale. In questo quaderno restano riportati integralmente per non perdere l'informazione originale.

# Prossime operazioni della campagna al 2 settembre

Ordine registrato nell'handoff:

1. Dopo la manutenzione, controllare `squeue`, lo stato del task 3 e `_SUCCESS` dalla finestra tmux `tesi:1:leo`.
2. Riclonare i metadati GitHub su Leonardo preservando `data/`, `logs/` e `container/geospatial.sif`.
3. Sincronizzare il container e gli output completati verso Spartaco.
4. Rimuovere il vecchio array in hold soltanto dopo aver confermato che il sostitutivo copre i task 4-167.
5. Verificare ogni specie completata con `_SUCCESS`, numero di file, dimensioni e log.
6. Aggiornare il manifest delle run.

Guardrail:

- iniziare le risposte con "Enrico" e comunicare in italiano;
- usare `tmux send-keys` per Leonardo;
- ispezionare il pane prima di inviare comandi;
- ripristinare il monitoraggio dei log dopo i comandi;
- richiedere approvazione esplicita prima di cambiare o cancellare job Slurm;
- committare soltanto file legati al task;
- il worktree principale può contenere modifiche della tesi non correlate.

Il pre-prompt associato richiedeva di leggere prima `prompt.md`, il quaderno LaTeX, `README.md` e `notes.md`, ricostruire in modo conciso stato della campagna, RAM, CPU, storage, test worker, esperimento MAXNET e prossimi passi. Specificava inoltre di:

- considerare `prompt.md` l'handoff principale;
- non lanciare job;
- non modificare file;
- non ripulire il worktree.

# Attività aperte consolidate

## Validazione scientifica

- Controllare che punti di occorrenza e raster ambientali abbiano lo stesso CRS, atteso WGS84/EPSG:4326.
- Nel container, verificare con `terra::crs(terra::rast("data/input/climate_vars/baseline/PC1.tif"), describe = TRUE)$code`.
- Riproiettare i punti se necessario e documentare il controllo nella tesi.
- Controllare warning GLM, MAXNET, overflow interi, metriche mancanti e warning ensemble.
- Verificare se `scale.models=FALSE` serve ancora esplicitamente.
- Convertire gli output di valutazione da testo a CSV.
- Verificare gli acronimi GCM e SSP.
- Correggere il commento storico 5 GCM/10 scenari se confermato che i dati restano 4/8.
- Estrarre e documentare metriche, incluse TSS e AUC/ROC.
- Definire quali raster individuali conservare oltre a ensemble, metriche e metadati.
- Misurare le dimensioni dell'output di più specie prima di stimare lo storage totale.
- Eseguire l'analisi hotspot, provare approcci paralleli e vettorizzati e documentare metodo, risultati, statistiche e limiti.

## Campagna Leonardo

- Usare i risultati da 4, 6 e 8 worker per scegliere e documentare una configurazione.
- Validare il test da 16 worker F/F e i suoi output prima di usarlo come evidenza.
- Mantenere il disegno una specie per task e al massimo tre nodi concorrenti.
- Decidere come gestire le specie fallite: raccolta errori, retry selettivo o arresto delle onde successive.
- Valutare shortest-job-first senza presentarlo come risparmio di costo totale.
- Registrare makespan, CPU-hours, MaxRSS, stato per specie, timing per fase e validazione output.
- Valutare uno script di monitoraggio Slurm per array e log.
- Verificare i task completati della campagna di produzione e aggiornare il manifest.

## Ottimizzazione del workflow

- Completare il confronto MAXNET blockwise sul raster completo con runtime, MaxRSS e uguaglianza degli output.
- Estendere il test a tutti i modelli e scenari necessari.
- Aggiornare `tests/expected_output_foreach_species.txt` soltanto se il contratto degli output cambia intenzionalmente.
- Scrivere una test suite per il codice in `R/`, usando `tests/test_output.R` se una revisione conferma che è una base utile e corretta.
- Verificare se la separazione dello script cambia memoria, parallelismo o riproducibilità.
- Misurare la contesa I/O con più worker.
- Ridurre ricalcoli e copie soltanto quando le misure lo giustificano.
- Passare il conteggio CPU Slurm a R tramite `BIOMOD_NCPU`.
- Aggiungere timestamp alle istruzioni e fasi rilevanti nei log R.
- Valutare il rilascio della RAM tra le fasi.
- Non usare automaticamente il disco senza misurarne l'effetto.
- Decidere se pulire `data/output/` prima di ogni run e automatizzare l'eliminazione di output obsoleti se necessario.
- Considerare `snowfall` soltanto se i test del backend interno BIOMOD2 lo richiedono ancora.
- Non passare a sharding multinodo prima di aver esaurito e misurato le soluzioni blockwise e per-specie.

## Infrastruttura e studio

- Completare e verificare il workflow rsync/rclone/scp tra computer locale, Serviicola, Leonardo e Spartaco.
- Documentare l'intero login CINECA da Linux.
- Decidere tra Forgejo e workflow rsync per dati grandi.
- Rimuovere credenziali dalle note e purgarle dalla storia Git.
- Studiare le operazioni Git lente sul filesystem HPC e valutare un trattamento diverso dei file grandi.
- Chiarire `message`, `print`, `cat` e `printf` in R.
- Finire `workflow-leo.sh`.
- Consolidare i vecchi script ensemble soltanto dopo averne capito le differenze.
- Verificare con Lucia i codici CINECA `IsCd6_SPECC` e `IscrC_SPECC`.
- Configurare formatter e LSP R, eventualmente con pre-commit.
- Tenere il Makefile come wrapper minimo ed estenderlo solo per comandi ricorrenti.
- Valutare CUDA in Rocker e SonarQube solo se diventano bisogni concreti.
- Ridurre l'output della definizione del container a errori e warning.
- Se necessario a settembre, chiedere ulteriori risorse CINECA.
- Rivedere SIMD/AVX e la nota di Mitchell Hashimoto.
- Completare gli esercizi HPC elencati in `R/tmp/hello-world.R`.
- Considerare `broom` soltanto se serve per estrarre metriche.
- Chiarire l'idea "supermarket scheduling" prima di trasformarla in requisito.
- Determinare se il sistema può eseguire Doom.

# Piano della tesi

## Tesi di lavoro

La tesi riguarda l'esecuzione e la misurazione su HPC di un workflow R/BIOMOD2 per Species Distribution Models. Il confronto principale riguarda la rappresentazione dei raster di proiezione e il numero di worker. I risultati scientifici devono restare separati dalle ottimizzazioni ancora sperimentali.

## Struttura proposta

1. **Introduction and motivation**: contesto ecoinformatico, problema computazionale, obiettivi e contributi.
2. **Background**: SDM, dati di presenza, raster ambientali, pseudo-assenze, ensemble e scenari climatici.
3. **Related work**: da scrivere dopo aver scelto riferimenti pertinenti. Le citazioni attuali nel `.bib` provengono in gran parte da un altro progetto e non vanno riusate automaticamente.
4. **Requirements analysis**: requisiti scientifici, funzionali, di riproducibilità, risorse e gestione degli errori.
5. **Design**: pipeline per specie, separazione calibrazione/proiezione, isolamento output e job array Slurm.
6. **Implementation**: R, BIOMOD2, Terra, Singularity, Leonardo e controlli introdotti.
7. **Experiments**: domande, configurazioni, metriche, confronto storage e worker.
8. **Discussion**: interpretazione, limiti, warning scientifici, generalizzabilità e compromessi RAM/I/O.
9. **Conclusions and future work**: risultati conclusivi e lavoro necessario per completare la campagna.
10. **Appendix**: frammenti di codice selezionati solo se aiutano la riproducibilità.

## Materiale già utilizzabile

- Dataset: 2.583.359 presenze, 167 specie, 1 km².
- Workflow: GLM, GBM, ANN, FDA, MAXNET; due ensemble; un ambiente corrente; otto scenari futuri.
- Storage: F/F completato a circa 261 GiB; F/T fallito durante la clamping mask.
- Worker: 4, 6 e 8 completati su *A. atrata*; 16 F/F notificato completo ma da validare; 32 F/F fallito OOM.
- MAXNET blockwise: 226.775 celle valide, NA identici e differenza assoluta massima zero; mancano raster completo, RAM, tempi e output.

## Regole di scrittura

- Separare risultato osservato, interpretazione e ipotesi.
- Indicare specie, configurazione, job, unità e numero di ripetizioni.
- Non presentare il registro sperimentale come risultato scientifico definitivo.
- Usare citazioni pertinenti e verificate.
- Non riempire il testo con riferimenti non collegati al progetto.
- Mantenere la tesi concisa e assertiva quando si passerà dagli appunti alla stesura.
- Non promettere il completamento della campagna prima della validazione.
- Scrivere e revisionare i capitoli usando risultati verificati.
- Confermare titolo, struttura, abstract e contenuto scientifico con i relatori.
- Sostituire i placeholder per relatore, correlatore, esaminatore e dedica.
- Decidere se l'abstract resta nel main o in `Chapters/abstract.tex`.
- Aggiungere figure e tabelle soltanto con dati e didascalie verificabili.
- Scegliere formato e template delle slide.
- Preparare una presentazione tecnica di circa un'ora e una non tecnica di circa 15 minuti.
- Considerare compilazione LaTeX automatica soltanto quando la struttura è stabile.
- Aggiungere un comando LaTeX per commenti e note rosse.
- Ricordare i suggerimenti del professore presenti in fondo a `docs/thesis/main.tex`.

# Regola storica di gestione delle note

L'organizzazione precedente prevedeva:

- `prompt.md` come handoff operativo principale;
- `docs/thesis/Chapters/notes.tex` come quaderno grezzo per misure, job, risultati e interpretazioni da verificare; durante quel riordino non doveva essere spostato né riscritto;
- `session-2026-07-03.md` come memoria della sessione iniziale, senza sostituire il quaderno;
- il TODO del `README.md` per attività future e decisioni operative sintetiche;
- `thesis-plan.md` per collegare i risultati ai capitoli;
- `docs/hpc-course/hpc notes.md` per gli appunti generali del corso HPC, separati dal progetto;
- `docs/slides/todo.txt` per note operative sulle slide già riflesse nel TODO.

Soltanto il materiale verificato, riscritto e approvato esplicitamente doveva passare negli altri capitoli LaTeX.

Dopo l'archiviazione, questo `appunti.md` diventa il punto unico per il materiale storico della cartella `work-in-progress`, ma non trasforma automaticamente le osservazioni in risultati scientifici definitivi.

## Matrice di copertura delle fonti archiviate

Questa matrice permette di rintracciare nel documento consolidato il contenuto dei file rimossi. Lo stato `COPERTO` significa che dati, decisioni, dubbi e riferimenti specifici della fonte sono riportati nelle sezioni indicate, anche quando sono stati tradotti o accorpati per evitare duplicazioni.

| Fonte rimossa | Stato | Sezioni di destinazione |
|---|---|---|
| `campaign-snapshot.md` | COPERTO | "Fase 9: campagna di produzione", sottosezione "Snapshot dello script". |
| `new-prompt.txt` | COPERTO | "Fase 9", "Modello operativo worktree, tmux e agent". |
| `notes.md` | COPERTO | "Mappa dei riferimenti e dei nomi", "Regola storica di gestione delle note". |
| `notes.tex` | COPERTO | "Contesto scientifico", fasi 1-8, inventario delle run, storage, MAXNET, spazio disco, misure, QoS e piano della tesi. |
| `notes.tex.bak` | COPERTO | "Fase 6: campagna a onde e confronto controllato dello storage" e sezioni sullo storage. |
| `pre-prompt.txt` | COPERTO | "Prossime operazioni della campagna al 2 settembre". |
| `prompt.md` | COPERTO | "Fase 9", "Workflow tra i tre host", "Prossime operazioni della campagna al 2 settembre" e aggiornamento documentale del 4 settembre. |
| `README.md` | COPERTO | "Regola storica di gestione delle note". |
| `run-manifest.md` | COPERTO | "Stato consolidato al 4 settembre" e "Esaurimento del budget DCGP". |
| `session-2026-07-03.md` | COPERTO | Fasi 3-5 e "Modalità sequenziale più prudente annotata il 3 luglio". |
| `thesis-plan.md` | COPERTO | "Contesto scientifico e obiettivo del lavoro" e "Piano della tesi". |

# Esaurimento del budget DCGP, 4 settembre 2026

## Cancellazione dell'array sostitutivo

Dopo la manutenzione del 2-4 settembre, l'array `55530303_[4-167%3]` ha ricevuto nodi di calcolo, ma nessuna task ha avviato lo script batch. Le 164 task sono rimaste attive da uno a sedici secondi e Slurm le ha registrate come `CANCELLED by 0` con `ExitCode 0:0`. Non è stato creato alcun file `logs/job_55530303_<task>.log`.

Il commento di accounting di Slurm riporta per le task esaminate:

```text
prolog controller: insufficient or expired budget
```

La cancellazione è quindi avvenuta nel prolog amministrativo, prima dell'esecuzione di Singularity, R o `scripts/sbatch.sh`. L'exit code zero non indica il completamento dell'analisi: nessun processo applicativo è partito e non ha quindi restituito un errore. La verifica dell'output ha trovato soltanto tre directory di specie e tre marker `_SUCCESS`, relativi alle task `55020903_1`, `_2` e `_3`. Nessuna specie con indice 4-167 è stata completata dall'array sostitutivo.

Le notifiche ricevute dipendono da `--mail-type=ARRAY_TASKS`: Slurm ha inviato una mail per ciascun elemento cancellato. Il vecchio array `55020903_[4-167%3]`, che era rimasto in `JobHeldUser`, è stato cancellato manualmente il 4 settembre dopo questa diagnosi.

## Stato del budget

I comandi usati su Leonardo sono:

```bash
saldo -b -u REDACTED_USERNAME --dcgp
saldo -r -u REDACTED_USERNAME -y 2026 --dcgp
```

Il primo ha riportato:

```text
periodo di validità: 12 febbraio - 12 novembre 2026
budget totale:       100.000 ore locali
consumo:             103.448 ore locali
percentuale:         103,4%
```

Il report giornaliero attribuisce tutte le 103.448:48:42 ore locali a 158 job dell'utente `REDACTED_USERNAME` sull'account `IscrC_SPECC`. Il progetto non era scaduto per data; aveva superato il budget assegnato.

## Come CINECA contabilizza le ore

CINECA misura il consumo in ore CPU effettive. La formula documentata è:

```text
BH = T * N * R * C
```

con:

- `T`: tempo trascorso del job in ore;
- `N`: numero di nodi allocati;
- `C`: core disponibili su ogni nodo, 112 per DCGP;
- `R`: frazione massima di nodo riservata considerando separatamente CPU, memoria e altre risorse.

Il fattore `R` è il massimo tra le frazioni richieste. Per la campagna:

```text
CPU:       8 / 112      = 0,071
memoria:   494000 / 494000 MB = 1
R:         max(0,071, 1) = 1
```

La direttiva `--mem=0` riserva tutta la memoria allocabile del nodo. Anche con sole otto CPU, la RAM impedisce ad altri job di usare il resto del nodo e porta il costo a 112 ore locali per ogni ora di esecuzione:

```text
BH = T * 1 * 1 * 112 = T * 112
```

Conta la memoria riservata, non il solo MaxRSS osservato. Le tre task di produzione chiedevano 494.000 MB, mentre il batch step ha raggiunto circa 316 GiB per `55020903_1`, 316 GiB per `_2` e 291 GiB per `_3`. Una futura riduzione della memoria richiesta potrebbe abbassare il fattore `R`, ma deve lasciare un margine verificato rispetto ai picchi e alla variabilità tra specie.

La regola completa è descritta nella documentazione CINECA: <https://docs.hpc.cineca.it/hpc/hpc_intro.html#budget-and-accounting>.

## Job con il consumo maggiore

La tabella usa `sacct` e applica il fattore di 112 ore locali per ora ai job che richiedevano 494.000 MB su un nodo DCGP.

| Job | Stato | Tempo trascorso | Ore locali circa | Motivo del costo |
|---|---|---:|---:|---|
| `46403582` | `COMPLETED` | 50h18m54s | 5.635 | Nodo completo per oltre due giorni. |
| `48325677_4` | cancellato dall'utente | 42h47m42s | 4.793 | Nodo completo rimasto allocato fino alla cancellazione. |
| `48325677_5` | cancellato dall'utente | 42h47m42s | 4.793 | Stessa durata e stessa allocazione del task precedente. |
| `49507005_3` | cancellato dall'utente | 38h12m41s | 4.280 | Una delle tre task concorrenti della campagna a onde. |
| `49507005_2` | cancellato dall'utente | 38h12m37s | 4.280 | Una delle tre task concorrenti della campagna a onde. |
| `49507005_1` | cancellato dall'utente | 38h12m21s | 4.279 | Una delle tre task concorrenti della campagna a onde. |
| `55020903_3` | `COMPLETED` | 33h58m37s | 3.805 | Task Agrostis della campagna di produzione. |
| `55020903_1` | `COMPLETED` | 25h36m42s | 2.869 | Task Achillea della campagna di produzione. |
| `47574797_3` | `COMPLETED` | 22h59m26s | 2.575 | Run sequenziale con memoria completa. |
| `48238919_3` | cancellato dall'utente | 22h40m40s | 2.540 | Il tempo già allocato resta contabilizzato. |

La cancellazione non annulla il consumo precedente: un job cancellato dopo 42 ore viene fatturato per le 42 ore durante le quali ha riservato le risorse.

## Perché alcuni giorni superano 10.000 ore

`saldo -r` concentra il costo sul giorno associato alla conclusione del job. Il 4 luglio risultano 10.546:47:28 ore locali. Quasi tutto il consumo deriva da `48325677_4` e `_5`, circa 4.793 ore ciascuno, più due job da circa quattro ore:

```text
2 * 42,795 h * 112 = circa 9.586 ore locali
4,492 h * 112      = circa   503 ore locali
4,086 h * 112      = circa   458 ore locali
```

Il 17 luglio risultano 13.650:42:56 ore locali. Le tre task `49507005_1`, `_2` e `_3` contribuirono per circa 12.838 ore. Altri tre job brevi o terminati in OOM portarono il totale a circa 13.650:

```text
3 * 38,2 h * 112 = circa 12.838 ore locali
5,42 h * 112     = circa    607 ore locali
1,59 h * 112     = circa    178 ore locali
0,24 h * 112     = circa     27 ore locali
```

Il campo `num.jobs=61` del 17 luglio include submission, elementi di array, dipendenze e job cancellati. Non indica 61 nodi attivi contemporaneamente. Il consumo principale proviene da sei allocazioni, soprattutto dalle tre task da oltre 38 ore.

## Impatto sulla campagna completa

Le prime tre specie della campagna hanno consumato insieme circa 9.076 ore locali. La media è circa 3.025 ore locali per specie. Una proiezione lineare sulle 164 specie rimanenti darebbe circa 496.000 ore locali aggiuntive. È soltanto una stima, perché durata e memoria possono variare tra specie, ma mostra che la campagna non può rientrare nel budget originario da 100.000 ore senza nuove risorse o una riduzione sostanziale del costo per specie.

Prima di inviare un nuovo array occorrono un'estensione del budget e una nuova stima basata sui tre completamenti. La richiesta di memoria va scelta usando i MaxRSS misurati invece di `--mem=0`, senza ridurre il margine necessario per evitare OOM.

# Verifica, pulizia e riallineamento documentale del 4 settembre 2026

Questa sezione registra le operazioni eseguite nella sessione di verifica successiva al decluttering. In quella sessione, `docs/work-in-progress/appunti.md` era ancora un file di lavoro non committato e raccoglieva anche queste operazioni.

## Verifica del repository principale

Il clone di Serviicola è `/home/ubuntu/tesi`. Il branch attivo è `main`, con HEAD e `origin/main` entrambi a:

```text
ff8991b fix(login): clarify standalone SSH login
```

Il controllo `git fsck --full --no-dangling` non ha prodotto segnalazioni. Il repository ha un solo worktree:

```text
/home/ubuntu/tesi
```

Sono state eseguite queste verifiche:

- `bash -n` sugli script Bash tracciati;
- parsing con `Rscript` degli script R tracciati;
- ricerca dei riferimenti operativi a `base_sequential_analysis.R`;
- controllo dei file grandi tracciati;
- controllo delle differenze con `git diff --check`;
- controllo dell’albero del submodule BIOMOD2.

Dopo il refactor, i riferimenti attivi al vecchio script `base_sequential_analysis.R` non esistono più. I riferimenti presenti nei log storici non sono codice eseguito e non sono stati modificati.

## BIOMOD2 e commit del submodule

È stato eseguito un fetch read-only di `origin/master` nel submodule `docs/biomod2`.

```text
HEAD locale submodule: 0392260ceff329b6df1ecd7d67629eac6479eedd
origin/master:         0392260ceff329b6df1ecd7d67629eac6479eedd
divergenza:            0 0
```

Non c'erano quindi modifiche da pullare e `make biomod2sync` non è stato eseguito. Il puntatore `0392260c` è già registrato anche in `origin/main` del repository principale, nel commit:

```text
93956c1 chore(thesis): update build and BIOMOD2
```

È stata cercata nella storia Git la stringa esatta:

```text
chore: update BIOMOD2 submodule
```

Non esiste alcun commit raggiungibile con quel subject. Il comando di ricerca è stato inizialmente eseguito con il pager configurato come `hunk`, che ha prodotto `hunk: not found`; la ricerca corretta senza pager è:

```bash
git --no-pager log --all \\
  --grep='^chore: update BIOMOD2 submodule$' \\
  --format='%H %ad %s' \\
  --date=short
```

## Correzione dei riferimenti R

Sono stati corretti due riferimenti lasciati dal rename degli script:

```text
R/tmp/baseline_blockwise.R
  source("R/base/baseline.R")

scripts/sbatch.sh
  readonly RSCRIPT_PATH="/work/R/base/baseline.R"
```

Il file `R/base/baseline.R` esiste e sia il file blockwise sia lo script batch superano i controlli di sintassi/parsing.

## Dichiarazioni `readonly`

In `scripts/3sync.sh` sono stati sostituiti soltanto i default autoriferiti con valori fissi:

```bash
readonly LEO_HOST="REDACTED_USERNAME@login.leonardo.cineca.it"
readonly LEO_ROOT="/leonardo_work/IscrC_SPECC"
readonly SPARTACO_HOST="user@REDACTED_HOST"
readonly SPARTACO_ROOT="F:/HPC_Leonardo"
readonly LEO_REMOTE="leo"
readonly SPARTACO_REMOTE="spartaco"
readonly SSH_AUTH_SOCK="$HOME/.ssh/cineca-agent.sock"
```

Non è stato cambiato il comportamento di trasferimento di `scripts/3sync.sh`. In particolare, non è stata aggiunta alcuna copia automatica del container nel clone locale di Serviicola.

## Documentazione aggiornata

Sono stati aggiornati:

- `README.md`;
- `data/README.md`;
- `docs/work-in-progress/prompt.md`;
- `docs/work-in-progress/run-manifest.md`.

La documentazione ora registra che:

- Serviicola, Leonardo e Spartaco conservano ciascuno il clone Git;
- `container/geospatial.sif` è presente sui tre computer ma è ignorato da Git;
- i dati pesanti sotto `data/` sono ignorati da Git;
- i dati pesanti sono conservati su Leonardo e Spartaco, non su Serviicola;
- `make 3sync` copia dati e container da Leonardo a Spartaco usando Serviicola come relay;
- i file di destinazione non vengono cancellati da `3sync`.

La tabella di `docs/work-in-progress/run-manifest.md` è stata aggiornata al 4 settembre 2026. Registra i tre task completati della campagna `55020903`, incluso `Agrostis.capillaris`, e l'assenza di job attivi dopo l'esaurimento del saldo ore.

## Controllo dei backup e delle copie locali

Prima della cancellazione erano presenti due snapshot completi:

```text
/home/ubuntu/tesi-declutter-safety-20260901-150933
/home/ubuntu/tesi-worktree-safety-20260901-135239
```

Entrambi occupavano circa 3,8 GiB. Contenevano `status.txt`, liste delle modifiche, un diff e `worktree.tar`; gli archivi includevano il container SIF da circa 1,5 GiB e i dati pesanti di input. I rispettivi SHA-256 di `worktree.tar` erano diversi, perché rappresentavano due momenti distinti:

```text
e5f64d808df8926c69d5012d2ed7eabbf3134e1e1c94632b9d5234c809b2fc52  tesi-declutter-safety-20260901-150933/worktree.tar
7b5dd2a6f0defbbb432468112c345611bf001a2a55b3a511e5e02aab01f320c1  tesi-worktree-safety-20260901-135239/worktree.tar
```

Era inoltre presente il clone di verifica:

```text
/home/ubuntu/tesi-verify-clean
```

Le tre directory sono state cancellate dopo aver verificato che il repository corrente contenesse il lavoro necessario e che il SIF corrente fosse ancora presente in:

```text
/home/ubuntu/tesi/container/geospatial.sif
```

Il SIF locale occupa circa 1,5 GiB. Dopo la pulizia, nella home resta soltanto `/home/ubuntu/tesi` tra le copie con nome `tesi` o `lfs` e `git worktree list` mostra un solo worktree.

## Controllo Git su Leonardo e Spartaco

Su Leonardo, usando la finestra tmux prevista per i comandi remoti, è stato fatto un fetch di `origin/main` e un confronto read-only. Il risultato è:

```text
HEAD Leonardo:  88e03c004bb9c45d9607ab76e4dbda1f6a6612e0
origin/main:    ff8991bcd56353cf25602c6259a11a0945ed2438
divergenza:     152 commit locali soltanto, 192 commit remoti soltanto
```

Leonardo contiene inoltre numerosi log non tracciati. Non sono stati eseguiti pull, reset, checkout, commit o cancellazioni su Leonardo.

Il controllo SSH diretto verso Spartaco (`user@REDACTED_HOST`) è stato rifiutato dalle credenziali disponibili:

```text
Permission denied (publickey,password,keyboard-interactive)
```

Non è quindi stato possibile stabilire da questa sessione se il clone Git di Spartaco abbia commit locali o modifiche in ingresso. Non sono state eseguite operazioni su Spartaco.

## Stato Git lasciato dalla sessione

Al termine di quella sessione, tutte le modifiche tracciabili prodotte o mantenute dovevano essere committate. `docs/work-in-progress/appunti.md` era stato escluso intenzionalmente ed era rimasto non tracciato in attesa di una review dedicata.
