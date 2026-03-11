#!/bin/bash

# Configuration
USER="REDACTED_USERNAME"
HOST="login.leonardo.cineca.it"
REMOTE_DIR="~/biomod-plus-plus"
CONTAINER="container.sif"
DEF_FILE="container.def"

echo "--- 🚀 Starting Leonardo Deployment ---"

# 1. Build the container locally (requires sudo)
echo "Building Apptainer image (this may take 10+ minutes)..."
sudo apptainer build $CONTAINER $DEF_FILE

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Check build.log for details."
    exit 1
fi

# 2. Create remote directory
echo "Preparing remote directory..."
ssh $USER@$HOST "mkdir -p $REMOTE_DIR"

# 3. Upload files
echo "Uploading container and project files..."
# Using rsync for efficiency (it only sends changes)
rsync -avz --progress $CONTAINER test.r data/ $USER@$HOST:$REMOTE_DIR/

echo "--- ✅ Deployment Complete ---"
echo "To run your project on Leonardo:"
echo "1. ssh $USER@$HOST"
echo "2. cd $REMOTE_DIR"
echo "3. sbatch job.sh  # (See the job script I created below)"