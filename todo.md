# todos

⚠️ Coerenza CRS punti↔raster (da verificare per la tesi — non un bug del codice, ma del dato)

In uno SDM due cose devono vivere nello stesso sistema di coordinate (CRS):
1. i punti di presenza specie (x,y del CSV);
2. i raster ambientali (PC1.tif, ecc.).
biomod2, per ogni punto, legge il valore del raster in quella posizione ("estrazione").
Se i CRS non coincidono, la posizione viene interpretata in modo diverso tra punti e
raster: il punto cade FUORI dalla griglia (valore NA) o nel posto sbagliato → BIOMOD_FormatingData
scarta le occorrenze e il modello esce vuoto o in errore.

I punti del CSV sono in gradi lon/lat WGS84 (~13–14°E, 47–48°N, Alpi austriache → EPSG:4326).
Se i raster fossero in un CRS proiettato (in metri, es. ETRS89-LAEA / EPSG:3035, comune per dati
europei), il valore 13.8 verrebbe letto come "13.8 metri" → fuori da tutto.

<!-- se trovasse sistema di coordinate, da errore subito -->

Verifica su Leonardo (nel container):
  terra::crs(terra::rast("data/input/climate_vars/baseline/PC1.tif"), describe=TRUE)$code
Atteso: 4326. Se torna altro (es. 3035) → riproiettare i punti prima di BIOMOD_FormatingData.
È esattamente il tipo di controllo da documentare nella sezione "preparazione dati" della tesi.

---
- [ ] inizia a scrivere tesi su quello che è gia stato fatto, appunti, logs, note, codice, etc...poi aggiornare la tesi scrivendo brevissimamente gli appunti/note direttamente lì in latex, invece che nel readme, anche quando inizierò a fare i vari grafici/hotspot analysis
- [ ] write a 'comment', or similar, command in latex for writing my comments/notes in red within the thesis text
- [ ] risolvi questione git lfs della mail @ todo.eml
    - host repo on my forgejo server? lucia would agree? if so, my ssd has enough storage? non-developer people how easy can see or update the non-github repo?
    - if not, implement a rsync workflow for lfs files, and find/brainstorm a way to share those data files
- [ ] passa il numero di cpu da usare in r (np.cpu) etc, tramite il sbatch.sh
- [ ] try to use snowfall (biomod function for parallelization) in addition to rest
    - it should replace the doParallel backend/package/function  
- [ ] delete data/output/* before every run
- [ ] print also timestamps for every command inside r script
- [ ] run hotspot analysis on r script on leonardo
- [ ] run hotspot analysis on r script on leonardo with parallelization, vectorization, etc
- [ ] write statistics and thesis sections about hotspot analysis, and so on

- [ ] TODO check what does this mean: (write a script to check the consistency of CRS between points and rasters, and to reproject points if needed (and document it in the thesis))

- [ ] <https://github.com/tidymodels/broom>

- [ ] adjust rsync-leo
- [ ] what's the difference between all the printing R methods (message, print, printf, cat, put, ...)
- [ ] finish workflow-leo.sh
- [ ] adjust the old.ensemble_modelling Rscripts into a single one, after having studied everyone of them and understanding the differences

- [ ] impostare autoformatter e LSP per R (forse anche con pre-commit hook)
- [ ] fare gli esercizi yt

- [ ] verify CINECA project codes: check with Lucia Doni whether IsCd6_SPECC and IscrC_SPECC are the same or different projects
- iscd6_specc è il nome del progetto
- iscrc_specc è l'id del progetto

- [ ] Full HPC run on Cineca Leonardo.
- [ ] Thesis document (`thesis.tex`) finalization.

- [ ] automate cleanup of dirty `data/output/` after a run (stale species dirs, case-dup `proj_CurrentEM`, `proj_Tmp*` leftovers) — e.g. wipe output before each run or a cleanup script
- [ ] redirect all prints of .def file to null, except errors and warnings
- [ ] use rocker image with CUDA support <https://rocker-project.org/images/versioned/cuda.html>
- [ ] add sonarcube bind and support

- [ ] if settembre, manda subito mail richiesta altre risorse a CINECA
