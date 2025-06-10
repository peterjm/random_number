#!/bin/bash

# This script will be the entrypoint for our Docker container.

# --- Configuration ---
# In a real system, you might pass the S3 path and Git SHA as arguments.
S3_PARAMS_PATH="s3://YOUR_BUCKET_NAME_HERE/parameters.json" # <-- IMPORTANT: We will replace this later
PARAMS_FILE="/tmp/parameters.json"

echo "Dispatcher script started."
echo "Running task for Array Index: $AWS_BATCH_JOB_ARRAY_INDEX"

# --- 1. Fetch Parameters ---
# Download the parameters file from S3. The AWS CLI is already in the container.
echo "Fetching parameters from $S3_PARAMS_PATH..."
aws s3 cp $S3_PARAMS_PATH $PARAMS_FILE
if [ $? -ne 0 ]; then
    echo "FATAL: Could not download parameters file."
    exit 1
fi

# --- 2. Select Task-Specific Parameter ---
# Use the 'jq' tool to parse the JSON and get the multiplier for this specific task.
# jq uses 0-based indexing, which matches the AWS_BATCH_JOB_ARRAY_INDEX.
MULTIPLIER=$(jq ".[$AWS_BATCH_JOB_ARRAY_INDEX].multiplier" $PARAMS_FILE)

if [ -z "$MULTIPLIER" ] || [ "$MULTIPLIER" == "null" ]; then
    echo "FATAL: Could not extract multiplier for index $AWS_BATCH_JOB_ARRAY_INDEX."
    exit 1
fi

echo "Selected multiplier for this task: $MULTIPLIER"

# --- 3. Execute the Business Logic ---
# In a real system, this is where you would activate a venv and run your script
# from the cloned git repo. Here, we just run the script directly.
echo "Running the python script..."
python /app/random_number.py --multiplier $MULTIPLIER

echo "Dispatcher script finished."
