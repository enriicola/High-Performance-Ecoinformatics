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

Verifica su Leonardo (nel container):
  terra::crs(terra::rast("data/input/climate_vars/baseline/PC1.tif"), describe=TRUE)$code
Atteso: 4326. Se torna altro (es. 3035) → riproiettare i punti prima di BIOMOD_FormatingData.
È esattamente il tipo di controllo da documentare nella sezione "preparazione dati" della tesi.

---

- [ ] <https://github.com/tidymodels/broom>

- [ ] adjust rsync-leo

- [ ] impostare autoformatter e LSP per R (forse anche con pre-commit hook)
- [ ] fare gli esercizi yt

- [ ] verify CINECA project codes: check with Lucia Doni whether IsCd6_SPECC and IscrC_SPECC are the same or different projects

- [ ] Full HPC run on Cineca Leonardo.
- [ ] Thesis document (`thesis.tex`) finalization.

- [ ] redirect all prints of .def file to null, except errors and warnings
- [ ] use rocker image with CUDA support <https://rocker-project.org/images/versioned/cuda.html>
- [ ] add sonarcube bind and support
