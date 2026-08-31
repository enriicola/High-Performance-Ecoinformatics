# Run manifest

Situazione rilevata il 2026-08-31.

| Run/output | Stato | Riferimento |
|---|---|---|
| `data/output` | trasferito a `F:\HPC_Leonardo\`; 11.268 file, 122 GB | `scripts/3sync.sh`; verifica Spartaco |
| Campaign `55020903_1` — `Achillea.atrata` | completata; `_SUCCESS`; 2.614 file | `logs/leonardo-raw/` |
| Campaign `55020903_2` — `Achillea.clusiana` | completata; `_SUCCESS`; 2.614 file | `logs/leonardo-raw/` |
| Campaign `55020903_3` — `Agrostis.capillaris` | in esecuzione; niente `_SUCCESS` | `logs/leonardo-raw/` |
| Benchmark `output_*` | conservati su Leonardo e Spartaco; circa 54 GB | `README.md`, `notes.md` |
| Snapshot dello script | archiviato e verificato | `docs/campaign-snapshot.md` |

La destinazione Spartaco resta piatta: `data/output/*` viene copiato direttamente in `F:\HPC_Leonardo\*`.
