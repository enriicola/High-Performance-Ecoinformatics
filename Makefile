ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
.PHONY: $(ARGS)
$(ARGS):
	@:

.PHONY: thesis slides container leogin unigin sbatch 3sync txt2csv biomod2sync

thesis:
	./scripts/compile-thesis.sh

slides:
	./scripts/compile-slides.sh

container:
	singularity build container/geospatial.sif container/geospatial.def

biomod2sync:
	./scripts/biomod2sync.sh

leogin:
	./scripts/leogin.sh $(ARGS)

unigin:
	./scripts/unigin.sh

sbatch:
	sbatch scripts/sbatch.sh $(ARGS)

3sync:
	./scripts/3sync.sh $(ARGS)

txt2csv:
	./scripts/txt2csv.sh $(ARGS)
