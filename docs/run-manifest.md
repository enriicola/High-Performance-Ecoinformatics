# Run manifest

Situazione rilevata il 2026-08-31.

| Run/output | Stato | Riferimento |
|---|---|---|
| `data/output` | trasferito a `F:\HPC_Leonardo\data\output\`; archivio corrente 135 GB | `scripts/3sync.sh`; verifica Spartaco |
| Campaign `55020903_1` — `Achillea.atrata` | completata; `_SUCCESS`; 2.614 file | `logs/leonardo-raw/` |
| Campaign `55020903_2` — `Achillea.clusiana` | completata; `_SUCCESS`; 2.614 file | `logs/leonardo-raw/` |
| Campaign `55020903_3` — `Agrostis.capillaris` | in esecuzione; niente `_SUCCESS` | `logs/leonardo-raw/` |
| Benchmark `output_*` | conservati su Leonardo e Spartaco; circa 54 GB | `docs/thesis/Chapters/notes.tex`, `docs/session-2026-07-03.md` |
| Snapshot dello script | archiviato e verificato | `docs/campaign-snapshot.md` |

Leonardo e Spartaco mantengono gli stessi percorsi relativi alla root del repository; i file pesanti vengono copiati con `scripts/3sync.sh`.
