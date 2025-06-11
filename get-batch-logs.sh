#!/bin/bash
# A robust script to fetch the logs for a specific child task of a Batch Array Job.
# It checks for SUCCEEDED, FAILED, and then active jobs to find the correct child job.

PARENT_JOB_ID="$1"
# Use the second argument as the index, or default to 0.
CHILD_INDEX=${2:-0}

if [ -z "$PARENT_JOB_ID" ]; then
  echo "Usage: ./get-batch-logs.sh <PARENT_JOB_ID> [CHILD_INDEX]"
  echo "Example: ./get-batch-logs.sh e53b9dc8-1678-41c2-b3f6-c0b6d85b046a 1"
  exit 1
fi

echo "--> Finding child job at index $CHILD_INDEX for parent: $PARENT_JOB_ID"

# --- Corrected JMESPath Query Logic ---
# First, look for the job in the SUCCEEDED state.
CHILD_JOB_ID=$(aws batch list-jobs \
  --array-job-id "$PARENT_JOB_ID" \
  --job-status SUCCEEDED \
  --query "jobSummaryList[?arrayProperties.index==\`$CHILD_INDEX\`].jobId" \
  --output text)

# If not found, look for it in the FAILED state.
if [ -z "$CHILD_JOB_ID" ]; then
  CHILD_JOB_ID=$(aws batch list-jobs \
    --array-job-id "$PARENT_JOB_ID" \
    --job-status FAILED \
    --query "jobSummaryList[?arrayProperties.index==\`$CHILD_INDEX\`].jobId" \
    --output text)
fi

# If still not found, check the active states (the default).
if [ -z "$CHILD_JOB_ID" ]; then
  CHILD_JOB_ID=$(aws batch list-jobs \
    --array-job-id "$PARENT_JOB_ID" \
    --query "jobSummaryList[?arrayProperties.index==\`$CHILD_INDEX\`].jobId" \
    --output text)
fi

# --- End Corrected Logic ---


if [ -z "$CHILD_JOB_ID" ]; then
  echo "Could not find a child job with index $CHILD_INDEX. Please check the Parent Job ID and index."
  exit 1
fi

echo "--> Found child job ID: $CHILD_JOB_ID"
LOG_STREAM_NAME=$(aws batch describe-jobs --jobs "$CHILD_JOB_ID" --query "jobs[0].container.logStreamName" --output text)

if [ -z "$LOG_STREAM_NAME" ] || [ "$LOG_STREAM_NAME" == "None" ]; then
    echo "Could not find log stream. The task may have failed before it could start logging."
    echo "Checking the status reason..."
    aws batch describe-jobs --jobs "$CHILD_JOB_ID" --query "jobs[0].statusReason"
    exit 1
fi

echo "--> Found log stream: $LOG_STREAM_NAME"
echo "--- LOGS START (Index: $CHILD_INDEX) ---"
aws logs get-log-events --log-group-name /aws/batch/job --log-stream-name "$LOG_STREAM_NAME" --query "events[*].message" --output text
echo "--- LOGS END ---"
