#!/bin/bash
USER="REDACTED_USERNAME"
HOST="login.leonardo.cineca.it"
REMOTE_DIR="biomod-plus-plus"
CONTAINER="container.sif"

echo "--- 🚀 Deploying Biomod++ to Leonardo ---"

# Build (skip if already exists and you don't want to rebuild)
# sudo apptainer build $CONTAINER container.def

# Sync files (test.r, data folder, job.sh, container.sif)
rsync -avz --progress $CONTAINER test.r data/ job.sh $USER@$HOST:~/

echo "--- ✅ Sync Complete! ---"
echo "Instructions:"
echo "1. Connect: ssh $USER@$HOST"
echo "2. Check your account ID: saldo -u $USER"
echo "3. Update job.sh with the ID: nano job.sh"
echo "4. Submit the job: sbatch job.sh"
