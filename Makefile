.PHONY: thesis container leogin sbatch sync txt2csv

thesis:
	./scripts/compile-thesis.sh

container:
	singularity build container/geospatial.sif container/geospatial.def

leogin:
	./scripts/leogin.sh $(ARGS)

sbatch:
	sbatch scripts/sbatch.sh $(ARGS)

sync:
	./scripts/3sync.sh $(ARGS)

txt2csv:
	./scripts/txt2csv.sh $(ARGS)

