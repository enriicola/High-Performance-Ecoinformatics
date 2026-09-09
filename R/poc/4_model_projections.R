# Step 4: individual model projection on current conditions.

project_models <- function(models, environment, projection_name, run_cfg, species_seed) {
  BIOMOD_Projection(
    bm.mod = models,
    proj.name = projection_name,
    new.env = environment,
    models.chosen = "all",
    build.clamping.mask = run_cfg$science$projection_build_clamping_mask,
    keep.in.memory = run_cfg$science$projection_keep_in_memory,
    do.stack = run_cfg$science$projection_do_stack,
    nb.cpu = run_cfg$model_workers,
    seed.val = species_seed
  )
}
